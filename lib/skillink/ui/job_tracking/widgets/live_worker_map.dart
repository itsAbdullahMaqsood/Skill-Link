import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skilllink/skillink/data/services/directions_service.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

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
  bool _didInitialFit = false;
  StreamSubscription<({double lat, double lng})>? _sub;

  List<LatLng>? _routePoints;

  LatLng? _lastRouteAnchor;
  bool _isFetchingRoute = false;
  Timer? _routeDebounce;

  static const double _routeRefreshMeters = 150;

  final DirectionsService _directions = DirectionsService();

  BitmapDescriptor? _workerIcon;

  LatLng get _home => LatLng(widget.homeLocation.lat, widget.homeLocation.lng);

  LatLng get _seededWorker => LatLng(
        widget.homeLocation.lat + 0.006,
        widget.homeLocation.lng + 0.006,
      );

  LatLng get _effectiveWorker => _worker ?? _seededWorker;

  @override
  void initState() {
    super.initState();
    _loadWorkerIcon();

    _scheduleRouteFetch();

    _sub = widget.locationStream.listen(
      (p) {
        if (!mounted) return;
        setState(() => _worker = LatLng(p.lat, p.lng));
        if (!_didInitialFit) {
          _didInitialFit = true;
          _fitBounds();
        }
        _scheduleRouteFetch();
      },
      onError: (Object _) {
        if (!mounted) return;
        setState(() => _mapFailed = true);
      },
    );
  }

  void _scheduleRouteFetch() {
    _routeDebounce?.cancel();
    _routeDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final w = _effectiveWorker;
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
    if (_isFetchingRoute) return;
    _isFetchingRoute = true;
    final origin = _effectiveWorker;
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
    final h = sinDLat * sinDLat +
        math.cos(_toRadians(a.latitude)) *
            math.cos(_toRadians(b.latitude)) *
            sinDLng *
            sinDLng;
    return 2 * earthRadius * math.asin(math.min(1, math.sqrt(h)));
  }

  static double _toRadians(double deg) => deg * math.pi / 180.0;

  Future<void> _fitBounds() async {
    final c = _controller;
    if (c == null) return;
    final w = _effectiveWorker;

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
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: _mapFailed
          ? _MapFallback(worker: _worker, home: _home)
          : Stack(
              children: [
                _buildMap(),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: _RecenterButton(onPressed: _fitBounds),
                ),
              ],
            ),
    );
  }

  Future<void> _loadWorkerIcon() async {
    final cached = _WorkerIconCache.instance;
    if (cached != null) {
      if (!mounted) return;
      setState(() => _workerIcon = cached);
      return;
    }
    final descriptor = await _WorkerIconCache.load();
    if (!mounted) return;
    setState(() => _workerIcon = descriptor);
  }

  Widget _buildMap() {
    final w = _effectiveWorker;
    final initialTarget = LatLng(
      (w.latitude + _home.latitude) / 2,
      (w.longitude + _home.longitude) / 2,
    );

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialTarget, zoom: 13),
      onMapCreated: (c) {
        _controller = c;
        if (!_didInitialFit) {
          _didInitialFit = true;
          _fitBounds();
        }
      },
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
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
        Marker(
          markerId: const MarkerId('worker'),
          position: w,
          icon: _workerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
          anchor: const Offset(0.5, 1.0),
          infoWindow: InfoWindow(
            title: 'Worker',
            snippet: _worker == null ? 'Approx. location' : 'Live',
          ),
        ),
      },
      polylines: _buildPolylines(w),
    );
  }

  Set<Polyline> _buildPolylines(LatLng worker) {
    final road = _routePoints;
    final points = (road != null && road.length >= 2) ? road : <LatLng>[_home, worker];
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
          child: Icon(Icons.my_location_rounded,
              size: 20, color: AppColors.primary),
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
          const Icon(Icons.map_outlined,
              size: 32, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(
            'Live map unavailable',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Home: '
            '${home.latitude.toStringAsFixed(4)}, '
            '${home.longitude.toStringAsFixed(4)}',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            worker == null
                ? 'Waiting for worker location…'
                : 'Worker: '
                    '${worker!.latitude.toStringAsFixed(4)}, '
                    '${worker!.longitude.toStringAsFixed(4)}',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WorkerIconCache {
  static BitmapDescriptor? _cached;
  static Future<BitmapDescriptor?>? _inFlight;

  static const int _targetPx = 96;

  static BitmapDescriptor? get instance => _cached;

  static Future<BitmapDescriptor?> load() {
    if (_cached != null) return Future.value(_cached);
    return _inFlight ??= _decode().whenComplete(() => _inFlight = null);
  }

  static Future<BitmapDescriptor?> _decode() async {
    try {
      final svg = await rootBundle.loadString('assets/icons/worker.svg');
      final match = RegExp(r'base64,([^"\s]+)').firstMatch(svg);
      if (match == null) return null;
      final b64 = match.group(1);
      if (b64 == null || b64.isEmpty) return null;
      final pngBytes = base64Decode(b64);

      final codec = await ui.instantiateImageCodec(
        pngBytes,
        targetWidth: _targetPx,
        targetHeight: _targetPx,
      );
      final frame = await codec.getNextFrame();
      final resized = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (resized == null) return null;

      final descriptor = BitmapDescriptor.bytes(
        Uint8List.view(resized.buffer),
      );
      _cached = descriptor;
      return descriptor;
    } on Exception {
      return null;
    }
  }
}
