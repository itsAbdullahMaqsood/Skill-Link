import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/services/directions_service.dart';
import 'package:skilllink/skillink/data/services/eta_service.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/utils/result.dart';
import 'package:skilllink/skillink/utils/worker_marker_bitmap.dart';

/// Homeowner-facing live tracking map: shows worker marker, destination marker,
/// road polyline, and ETA. Subscribes to `/workerLocations/{workerId}` in RTDB.
///
/// Mounted by `sent_request_detail_screen.dart` for any request in the
/// `bidReceived`, `bidAccepted`, or `onTheWay` window so the homeowner sees
/// the worker once they are sharing location (from first bid onward).
class LiveTrackingMap extends ConsumerStatefulWidget {
  const LiveTrackingMap({
    super.key,
    required this.workerId,
    required this.serviceAddress,
    this.status,
    this.allowUserPanAndZoom = true,
    this.mapHeight = 240,
    this.routeLineColor,
  });

  final String workerId;
  final String serviceAddress;

  /// Current request status. Used only to tailor the skeleton message shown
  /// while the worker hasn't published a fix yet.
  final ServiceRequestStatus? status;

  /// When `false` (e.g. map embedded in the bids card), the user cannot pan,
  /// zoom, tilt, or rotate — parent scroll still works.
  final bool allowUserPanAndZoom;

  final double mapHeight;

  /// When set (e.g. red in the bids card), road and fallback polylines use
  /// this color instead of [AppColors.primary].
  final Color? routeLineColor;

  @override
  ConsumerState<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends ConsumerState<LiveTrackingMap>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  GoogleMapController? _map;
  LatLng? _destination;
  Set<Polyline> _polylines = const {};
  String? _lastRouteKey;
  String? _lastCameraFitKey;
  Timer? _routeRefresh;
  Timer? _cameraFitDebounce;
  DateTime? _lastLoggedUpdateAt;
  BitmapDescriptor? _workerMarkerIcon;

  static const double _boundsPaddingPx = 52;

  @override
  void initState() {
    super.initState();
    _resolveDestination();
    _loadWorkerMarkerIcon();
  }

  @override
  void didUpdateWidget(LiveTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workerId != widget.workerId ||
        oldWidget.serviceAddress != widget.serviceAddress) {
      _lastCameraFitKey = null;
    }
  }

  Future<void> _loadWorkerMarkerIcon() async {
    final cached = WorkerMarkerBitmap.cachedOrNull;
    if (cached != null) {
      if (!mounted) return;
      setState(() => _workerMarkerIcon = cached);
      return;
    }
    final icon = await WorkerMarkerBitmap.load();
    if (!mounted) return;
    setState(() => _workerMarkerIcon = icon);
  }

  @override
  void dispose() {
    _routeRefresh?.cancel();
    _cameraFitDebounce?.cancel();
    super.dispose();
  }

  /// Used when [CameraUpdate.newLatLngBounds] is unreliable (map not laid out
  /// yet, or platform quirks). Zoom is derived from separation of the two pts.
  double _zoomLevelForLatLngSpan(double latSpan, double lngSpan) {
    final s = math.max(latSpan, lngSpan);
    if (s <= 1e-8) return 12;
    if (s > 2.5) return 8;
    if (s > 1.0) return 9;
    if (s > 0.4) return 10;
    if (s > 0.15) return 11;
    if (s > 0.06) return 12;
    if (s > 0.025) return 13;
    return 14;
  }

  Future<void> _animateCameraCenterZoom(LatLng center, double zoom) async {
    final c = _map;
    if (c == null || !mounted) return;
    try {
      await c.animateCamera(CameraUpdate.newLatLngZoom(center, zoom));
    } on Object catch (e) {
      debugPrint('[LiveTrackingMap] center+zoom failed: $e');
    }
  }

  /// Expands degenerate bounds so [CameraUpdate.newLatLngBounds] never fails.
  LatLngBounds _boundsForTwoPoints(LatLng a, LatLng b) {
    var swLat = math.min(a.latitude, b.latitude);
    var swLng = math.min(a.longitude, b.longitude);
    var neLat = math.max(a.latitude, b.latitude);
    var neLng = math.max(a.longitude, b.longitude);
    const minSpan = 0.002;
    if (neLat - swLat < minSpan) {
      final mid = (swLat + neLat) / 2;
      swLat = mid - minSpan / 2;
      neLat = mid + minSpan / 2;
    }
    if (neLng - swLng < minSpan) {
      final mid = (swLng + neLng) / 2;
      swLng = mid - minSpan / 2;
      neLng = mid + minSpan / 2;
    }
    return LatLngBounds(
      southwest: LatLng(swLat, swLng),
      northeast: LatLng(neLat, neLng),
    );
  }

  Future<void> _animateCameraToIncludeBoth(LatLng worker, LatLng dest) async {
    if (_map == null || !mounted) return;
    // Bounds APIs often fail or no-op until the map has non-zero size; wait
    // for layout + platform tile init.
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted || _map == null) return;

    final c = _map!;
    final bounds = _boundsForTwoPoints(worker, dest);
    final center = LatLng(
      (worker.latitude + dest.latitude) / 2,
      (worker.longitude + dest.longitude) / 2,
    );
    final latSpan = (worker.latitude - dest.latitude).abs();
    final lngSpan = (worker.longitude - dest.longitude).abs();
    final heuristicZoom = _zoomLevelForLatLngSpan(latSpan, lngSpan);

    try {
      await c.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, _boundsPaddingPx),
      );
    } on Object catch (e) {
      debugPrint('[LiveTrackingMap] newLatLngBounds failed: $e — using heuristic zoom');
      await _animateCameraCenterZoom(center, heuristicZoom);
    }
  }

  Future<void> _animateCameraWorkerOnly(LatLng worker) async {
    final c = _map;
    if (c == null || !mounted) return;
    try {
      await c.animateCamera(CameraUpdate.newLatLngZoom(worker, 14));
    } on Exception {
      await c.animateCamera(CameraUpdate.newLatLng(worker));
    }
  }

  /// Debounced fit: last rebuild wins so GPS noise does not constantly move the
  /// camera; skips duplicate bounds after the same worker/destination pair.
  void _scheduleCameraFit(LatLng worker, LatLng? dest) {
    _cameraFitDebounce?.cancel();
    _cameraFitDebounce = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      final key = dest == null
          ? 'w${worker.latitude.toStringAsFixed(4)},${worker.longitude.toStringAsFixed(4)}|nodest'
          : 'w${worker.latitude.toStringAsFixed(4)},${worker.longitude.toStringAsFixed(4)}|d${dest.latitude.toStringAsFixed(5)},${dest.longitude.toStringAsFixed(5)}';
      if (_lastCameraFitKey == key) return;
      _lastCameraFitKey = key;
      if (dest != null) {
        unawaited(_animateCameraToIncludeBoth(worker, dest));
      } else {
        unawaited(_animateCameraWorkerOnly(worker));
      }
    });
  }

  Future<void> _resolveDestination() async {
    final geo = ref.read(geocodingCacheProvider);
    final coords = await geo.resolve(widget.serviceAddress);
    if (!mounted) return;
    if (coords != null) {
      setState(() {
        _destination = LatLng(coords.lat, coords.lng);
        _lastCameraFitKey = null;
      });
    }
  }

  Color get _lineColor => widget.routeLineColor ?? AppColors.primary;

  Future<void> _refreshRoute(LatLng worker, LatLng dest) async {
    final key =
        '${worker.latitude.toStringAsFixed(4)},${worker.longitude.toStringAsFixed(4)}';
    if (_lastRouteKey == key) return;
    final res = await DirectionsService()
        .fetchRoute(origin: worker, destination: dest);
    if (!mounted) return;
    if (res case Success(:final value)) {
      _lastRouteKey = key;
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            color: _lineColor,
            width: 5,
            points: value,
          ),
        };
      });
    } else {
      // Road API failed or key missing: still show a real-time straight line
      // so the route is visible in the bid card.
      _lastRouteKey = key;
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route-fallback'),
            color: _lineColor,
            width: 4,
            points: <LatLng>[worker, dest],
            patterns: <PatternItem>[
              PatternItem.dash(20),
              PatternItem.gap(10),
            ],
          ),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final liveAsync =
        ref.watch(workerLiveLocationProvider(widget.workerId));

    final placeholderHeight =
        widget.mapHeight < 160 ? 160.0 : widget.mapHeight;

    return liveAsync.when(
      loading: () =>
          _Skeleton(message: 'Connecting…', height: placeholderHeight),
      error: (e, _) => _Skeleton(
        message: 'Could not load live location.',
        height: placeholderHeight,
      ),
      data: (live) {
        if (live == null) {
          return _Skeleton(
            message: _waitingMessageFor(widget.status),
            height: placeholderHeight,
          );
        }
        final workerLatLng = LatLng(live.lat, live.lng);

        if (_lastLoggedUpdateAt != live.updatedAt) {
          _lastLoggedUpdateAt = live.updatedAt;
          debugPrint(
            '[LiveTrackingMap] new fix lat=${live.lat.toStringAsFixed(6)} '
            'lng=${live.lng.toStringAsFixed(6)} '
            'updatedAt=${live.updatedAt.toIso8601String()}',
          );
        }

        final dest = _destination;

        final CameraPosition initialCam = dest != null
            ? CameraPosition(
                target: LatLng(
                  (workerLatLng.latitude + dest.latitude) / 2,
                  (workerLatLng.longitude + dest.longitude) / 2,
                ),
                zoom: _zoomLevelForLatLngSpan(
                  (workerLatLng.latitude - dest.latitude).abs(),
                  (workerLatLng.longitude - dest.longitude).abs(),
                ),
              )
            : CameraPosition(target: workerLatLng, zoom: 14);

        final markers = <Marker>{
          Marker(
            markerId: const MarkerId('worker'),
            position: workerLatLng,
            icon: _workerMarkerIcon ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            anchor: const Offset(0.5, 1.0),
            infoWindow: const InfoWindow(title: 'Worker'),
          ),
          if (dest != null)
            Marker(
              markerId: const MarkerId('destination'),
              position: dest,
              infoWindow: const InfoWindow(title: 'Destination'),
            ),
        };

        if (dest != null) {
          unawaited(_refreshRoute(workerLatLng, dest));
        }

        final serviceAddr = widget.serviceAddress.trim();
        final etaAsync = serviceAddr.isEmpty
            ? null
            : ref.watch(
                liveCoordinateEtaProvider(
                  (
                    workerLat: live.lat,
                    workerLng: live.lng,
                    serviceAddress: serviceAddr,
                  ),
                ),
              );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _scheduleCameraFit(workerLatLng, dest);
        });

        final interactive = widget.allowUserPanAndZoom;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: widget.mapHeight,
                child: GoogleMap(
                  // Recreate when destination geocoding completes; otherwise
                  // [initialCameraPosition] stays stuck on worker-only zoom.
                  key: ValueKey<String>(
                    dest == null
                        ? 'live-map-geocoding'
                        : 'live-map-${dest.latitude.toStringAsFixed(4)}'
                            '_${dest.longitude.toStringAsFixed(4)}',
                  ),
                  initialCameraPosition: initialCam,
                  markers: markers,
                  polylines: _polylines,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: interactive,
                  zoomGesturesEnabled: interactive,
                  rotateGesturesEnabled: interactive,
                  tiltGesturesEnabled: interactive,
                  gestureRecognizers: interactive
                      ? <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        }
                      : const <Factory<OneSequenceGestureRecognizer>>{},
                  onMapCreated: (c) {
                    _map = c;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _scheduleCameraFit(workerLatLng, dest);
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.directions_car_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: etaAsync == null
                      ? Text(
                          'Live location active',
                          style:
                              AppTypography.titleLarge.copyWith(fontSize: 14),
                        )
                      : etaAsync.when(
                          loading: () => Text(
                            'Calculating route…',
                            style: AppTypography.titleLarge.copyWith(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                          error: (_, _) => Text(
                            'Live location active',
                            style:
                                AppTypography.titleLarge.copyWith(fontSize: 14),
                          ),
                          data: (EtaResult? eta) {
                            if (eta == null) {
                              return Text(
                                'Live location active',
                                style: AppTypography.titleLarge
                                    .copyWith(fontSize: 14),
                              );
                            }
                            return Text(
                              'ETA ~${eta.minutes} min · '
                              '${eta.distanceKm.toStringAsFixed(1)} km',
                              style: AppTypography.titleLarge
                                  .copyWith(fontSize: 14),
                            );
                          },
                        ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatUpdatedAt(live.updatedAt),
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _waitingMessageFor(ServiceRequestStatus? status) {
    switch (status) {
      case ServiceRequestStatus.onTheWay:
        return 'Waiting for the worker to share their location.\nThey should appear here in a moment.';
      case ServiceRequestStatus.bidReceived:
      case ServiceRequestStatus.bidAccepted:
        return 'Waiting for the worker to share their location.\nThey’ll appear here as soon as they’re ready.';
      default:
        return 'Waiting for the worker to share their location.';
    }
  }

  String _formatUpdatedAt(DateTime ts) {
    final diff = DateTime.now().toUtc().difference(ts.toUtc());
    if (diff.inSeconds < 30) return 'Just now';
    if (diff.inMinutes < 1) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.message, this.height = 180});
  final String message;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
