import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skilllink/skillink/data/services/directions_service.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/utils/haversine.dart';
import 'package:skilllink/skillink/utils/worker_marker_bitmap.dart';

class LiveWorkerMap extends StatefulWidget {
  const LiveWorkerMap({
    super.key,
    required this.locationStream,
    required this.homeLocation,
  });

  final Stream<({double lat, double lng})> locationStream;

  final ({double lat, double lng}) homeLocation;

  @override
  State<LiveWorkerMap> createState() => _LiveWorkerMapState();
}

class _LiveWorkerMapState extends State<LiveWorkerMap> {
  GoogleMapController? _controller;
  LatLng? _worker;
  bool _mapFailed = false;

  /// First time we have both a controller and a real worker fix; fit both.
  bool _didFitWorkerBounds = false;
  StreamSubscription<({double lat, double lng})>? _sub;

  List<LatLng>? _routePoints;

  LatLng? _lastRouteAnchor;
  bool _isFetchingRoute = false;
  Timer? _routeDebounce;
  DateTime? _lastFixAt;

  static const double _routeRefreshMeters = 150;

  final DirectionsService _directions = DirectionsService();

  BitmapDescriptor? _workerIcon;

  LatLng get _home => LatLng(widget.homeLocation.lat, widget.homeLocation.lng);

  @override
  void initState() {
    super.initState();
    _loadWorkerIcon();

    _sub = widget.locationStream.listen(
      (p) {
        if (!mounted) return;
        setState(() {
          _worker = LatLng(p.lat, p.lng);
          _lastFixAt = DateTime.now().toUtc();
        });
        _maybeFitWorkerBounds();
        _scheduleRouteFetch();
      },
      onError: (Object _) {
        if (!mounted) return;
        setState(() => _mapFailed = true);
      },
    );
  }

  void _maybeFitWorkerBounds() {
    if (_worker == null || _controller == null) return;
    if (_didFitWorkerBounds) return;
    _didFitWorkerBounds = true;
    unawaited(_fitBounds());
  }

  void _scheduleRouteFetch() {
    if (_worker == null) return;
    _routeDebounce?.cancel();
    _routeDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final w = _worker;
      if (w == null) return;
      final anchor = _lastRouteAnchor;
      if (anchor != null &&
          _metersBetween(anchor, w) < _routeRefreshMeters &&
          _routePoints != null &&
          _routePoints!.isNotEmpty) {
        return;
      }
      _fetchRoute();
    });
  }

  Future<void> _fetchRoute() async {
    if (_worker == null) return;
    if (_isFetchingRoute) return;
    _isFetchingRoute = true;
    final origin = _worker!;
    final destination = _home;
    final res = await _directions.fetchRoute(
      origin: origin,
      destination: destination,
    );
    if (!mounted) {
      _isFetchingRoute = false;
      return;
    }
    res.when(
      success: (points) {
        setState(() {
          _routePoints = points;
          _lastRouteAnchor = origin;
        });
      },
      failure: (_, _) {
        if (_routePoints == null) {
          setState(() => _routePoints = const <LatLng>[]);
        }
      },
    );
    _isFetchingRoute = false;
  }

  static double _metersBetween(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(b.latitude - a.latitude);
    final dLng = _toRadians(b.longitude - a.longitude);
    final sinDLat = math.sin(dLat / 2);
    final sinDLng = math.sin(dLng / 2);
    final h =
        sinDLat * sinDLat +
        math.cos(_toRadians(a.latitude)) *
            math.cos(_toRadians(b.latitude)) *
            sinDLng *
            sinDLng;
    return 2 * earthRadius * math.asin(math.min(1, math.sqrt(h)));
  }

  static double _toRadians(double deg) => deg * math.pi / 180.0;

  Future<void> _fitHomeOnly() async {
    final c = _controller;
    if (c == null) return;
    try {
      await c.animateCamera(CameraUpdate.newLatLngZoom(_home, 14));
    } on Exception {
      await c.animateCamera(CameraUpdate.newLatLng(_home));
    }
  }

  Future<void> _fitBounds() async {
    final c = _controller;
    if (c == null) return;
    final w = _worker;
    if (w == null) {
      await _fitHomeOnly();
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(
        math.min(w.latitude, _home.latitude),
        math.min(w.longitude, _home.longitude),
      ),
      northeast: LatLng(
        math.max(w.latitude, _home.latitude),
        math.max(w.longitude, _home.longitude),
      ),
    );
    try {
      await c.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } on Exception {
      await c.animateCamera(CameraUpdate.newLatLng(w));
    }
  }

  @override
  void dispose() {
    _routeDebounce?.cancel();
    _sub?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_mapFailed) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: _MapFallback(worker: _worker, home: _home),
      );
    }

    final w = _worker;
    final etaMin = w == null
        ? null
        : etaMinutesFromHaversine(
            w.latitude,
            w.longitude,
            _home.latitude,
            _home.longitude,
          );
    final distanceKm = w == null
        ? null
        : haversineKm(w.latitude, w.longitude, _home.latitude, _home.longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              _buildMap(),
              Positioned(
                right: 12,
                bottom: 12,
                child: _RecenterButton(
                  onPressed: () {
                    if (_worker == null) {
                      unawaited(_fitHomeOnly());
                    } else {
                      unawaited(_fitBounds());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (etaMin != null && distanceKm != null) ...[
          Row(
            children: [
              const Icon(
                Icons.directions_car_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'ETA ~$etaMin min · ${distanceKm!.toStringAsFixed(1)} km',
                  style: AppTypography.titleLarge.copyWith(fontSize: 14),
                ),
              ),
              Text(
                _formatFixAge(_lastFixAt ?? DateTime.now().toUtc()),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ],
    );
  }

  String _formatFixAge(DateTime ts) {
    final diff = DateTime.now().toUtc().difference(ts.toUtc());
    if (diff.inSeconds < 30) return 'Just now';
    if (diff.inMinutes < 1) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  Future<void> _loadWorkerIcon() async {
    final cached = WorkerMarkerBitmap.cachedOrNull;
    if (cached != null) {
      if (!mounted) return;
      setState(() => _workerIcon = cached);
      return;
    }
    final descriptor = await WorkerMarkerBitmap.load();
    if (!mounted) return;
    setState(() => _workerIcon = descriptor);
  }

  Widget _buildMap() {
    final w = _worker;
    final initialTarget = w == null
        ? _home
        : LatLng(
            (w.latitude + _home.latitude) / 2,
            (w.longitude + _home.longitude) / 2,
          );
    final initialZoom = w == null ? 14.0 : 13.0;

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: initialZoom,
      ),
      onMapCreated: (c) {
        _controller = c;
        if (w != null) {
          _maybeFitWorkerBounds();
        } else {
          unawaited(_fitHomeOnly());
        }
      },
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      compassEnabled: true,
      markers: {
        Marker(
          markerId: const MarkerId('home'),
          position: _home,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: 'Home'),
        ),
        if (w != null)
          Marker(
            markerId: const MarkerId('worker'),
            position: w,
            icon:
                _workerIcon ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            anchor: const Offset(0.5, 1.0),
            infoWindow: const InfoWindow(title: 'Worker', snippet: 'Live'),
          ),
      },
      polylines: _buildPolylines(w),
    );
  }

  Set<Polyline> _buildPolylines(LatLng? worker) {
    if (worker == null) return {};
    final road = _routePoints;
    final points = (road != null && road.length >= 2)
        ? road
        : <LatLng>[_home, worker];
    return <Polyline>{
      Polyline(
        polylineId: const PolylineId('home-to-worker'),
        color: AppColors.primary,
        width: 5,
        points: points,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }
}

class _RecenterButton extends StatelessWidget {
  const _RecenterButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.my_location_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _MapFallback extends StatelessWidget {
  const _MapFallback({this.worker, required this.home});
  final LatLng? worker;
  final LatLng home;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, size: 32, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text('Live map unavailable', style: AppTypography.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Home: '
            '${home.latitude.toStringAsFixed(4)}, '
            '${home.longitude.toStringAsFixed(4)}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            worker == null
                ? 'Waiting for worker location…'
                : 'Worker: '
                      '${worker!.latitude.toStringAsFixed(4)}, '
                      '${worker!.longitude.toStringAsFixed(4)}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
