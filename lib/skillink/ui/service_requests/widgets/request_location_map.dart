import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/logic/service_request_actions.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/job_tracking/widgets/live_worker_map.dart';

class RequestLocationMap extends ConsumerWidget {
  const RequestLocationMap({
    super.key,
    required this.address,
    required this.viewer,
  });

  final String address;
  final ServiceRequestViewer viewer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final geocodeAsync = ref.watch(forwardGeocodeProvider(address));
    return geocodeAsync.when(
      loading: () => const _MapShell(
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => _MapPlaceholder(
        address: address,
        message: 'Map unavailable — could not locate this address.',
      ),
      data: (coords) {
        if (coords == null) {
          return _MapPlaceholder(
            address: address,
            message: 'Map unavailable — address could not be located.',
          );
        }
        return _RequestMap(
          homeLocation: coords,
          viewer: viewer,
          address: address,
        );
      },
    );
  }
}

class _RequestMap extends StatefulWidget {
  const _RequestMap({
    required this.homeLocation,
    required this.viewer,
    required this.address,
  });

  final ({double lat, double lng}) homeLocation;
  final ServiceRequestViewer viewer;
  final String address;

  @override
  State<_RequestMap> createState() => _RequestMapState();
}

class _RequestMapState extends State<_RequestMap> {
  final StreamController<({double lat, double lng})> _controller =
      StreamController<({double lat, double lng})>.broadcast();

  StreamSubscription<Position>? _positionSub;

  @override
  void initState() {
    super.initState();
    if (widget.viewer == ServiceRequestViewer.worker) {
      _startDeviceGps();
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _controller.close();
    super.dispose();
  }

  Future<void> _startDeviceGps() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      try {
        final pos = await Geolocator.getCurrentPosition();
        if (!mounted) return;
        _controller.add((lat: pos.latitude, lng: pos.longitude));
      } on Exception {
      }
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      ).listen(
        (pos) {
          if (!mounted) return;
          _controller.add((lat: pos.latitude, lng: pos.longitude));
        },
        onError: (_) {
        },
      );
    } on Exception {
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: LiveWorkerMap(
        locationStream: _controller.stream,
        homeLocation: widget.homeLocation,
      ),
    );
  }
}

class _MapShell extends StatelessWidget {
  const _MapShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.address, required this.message});
  final String address;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _MapShell(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 32,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textMuted),
            ),
            if (address.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                address,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
