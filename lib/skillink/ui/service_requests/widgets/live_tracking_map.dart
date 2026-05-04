import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/services/directions_service.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/utils/haversine.dart';
import 'package:skilllink/skillink/utils/result.dart';
import 'package:skilllink/skillink/utils/worker_marker_bitmap.dart';

/// Homeowner-facing live tracking map: shows worker marker, destination marker,
/// road polyline, and ETA. Subscribes to `/workerLocations/{workerId}` in RTDB.
///
/// Mounted by `sent_request_detail_screen.dart` for any request in the
/// `bidAccepted` or `onTheWay` window so the homeowner sees the worker on the
/// map the instant their bid is accepted, not only after the worker taps
/// "On the way".
class LiveTrackingMap extends ConsumerStatefulWidget {
  const LiveTrackingMap({
    super.key,
    required this.workerId,
    required this.serviceAddress,
    this.status,
  });

  final String workerId;
  final String serviceAddress;

  /// Current request status. Used only to tailor the skeleton message shown
  /// while the worker hasn't published a fix yet.
  final ServiceRequestStatus? status;

  @override
  ConsumerState<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends ConsumerState<LiveTrackingMap> {
  GoogleMapController? _map;
  LatLng? _destination;
  Set<Polyline> _polylines = const {};
  String? _lastRouteKey;
  Timer? _routeRefresh;
  DateTime? _lastLoggedUpdateAt;
  BitmapDescriptor? _workerMarkerIcon;

  @override
  void initState() {
    super.initState();
    _resolveDestination();
    _loadWorkerMarkerIcon();
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
    _map?.dispose();
    super.dispose();
  }

  Future<void> _resolveDestination() async {
    final geo = ref.read(geocodingCacheProvider);
    final coords = await geo.resolve(widget.serviceAddress);
    if (!mounted) return;
    if (coords != null) {
      setState(() => _destination = LatLng(coords.lat, coords.lng));
    }
  }

  Future<void> _refreshRoute(LatLng worker, LatLng dest) async {
    final key =
        '${worker.latitude.toStringAsFixed(4)},${worker.longitude.toStringAsFixed(4)}';
    if (_lastRouteKey == key) return;
    _lastRouteKey = key;
    final res = await DirectionsService()
        .fetchRoute(origin: worker, destination: dest);
    if (!mounted) return;
    if (res case Success(:final value)) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            color: AppColors.primary,
            width: 5,
            points: value,
          ),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveAsync =
        ref.watch(workerLiveLocationProvider(widget.workerId));

    return liveAsync.when(
      loading: () => _Skeleton(message: 'Connecting…'),
      error: (e, _) => _Skeleton(message: 'Could not load live location.'),
      data: (live) {
        if (live == null) {
          return _Skeleton(message: _waitingMessageFor(widget.status));
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

        final etaMin = dest == null
            ? null
            : etaMinutesFromHaversine(
                live.lat,
                live.lng,
                dest.latitude,
                dest.longitude,
              );
        final distanceKm = dest == null
            ? null
            : haversineKm(
                live.lat,
                live.lng,
                dest.latitude,
                dest.longitude,
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 240,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(live.lat, live.lng),
                    zoom: 14,
                  ),
                  markers: markers,
                  polylines: _polylines,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  onMapCreated: (c) => _map = c,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.directions_car_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  etaMin == null
                      ? 'Live location active'
                      : 'ETA ~$etaMin min · ${distanceKm!.toStringAsFixed(1)} km',
                  style: AppTypography.titleLarge.copyWith(fontSize: 14),
                ),
                const Spacer(),
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
  const _Skeleton({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
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
