import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Bitmap worker pin used on Google Maps (worker live map + homeowner tracking).
///
/// Decodes embedded PNG from [assets/icons/worker.svg] at [targetPx] logical px.
class WorkerMarkerBitmap {
  WorkerMarkerBitmap._();

  static BitmapDescriptor? _cached;
  static Future<BitmapDescriptor?>? _inFlight;
  static int? _cachedPixelSize;

  /// Default pin size on the map (both worker + homeowner).
  static const int defaultTargetPx = 50;

  static BitmapDescriptor? get cachedOrNull => _cached;

  /// Loads (and caches) the marker for [targetPx].
  ///
  /// If [targetPx] differs from a previously cached size, cache is rebuilt.
  static Future<BitmapDescriptor?> load({int targetPx = defaultTargetPx}) {
    if (_cached != null && _cachedPixelSize == targetPx) {
      return Future.value(_cached);
    }
    _cached = null;
    _cachedPixelSize = null;
    return _inFlight ??= _decode(targetPx).whenComplete(() => _inFlight = null);
  }

  static Future<BitmapDescriptor?> _decode(int targetPx) async {
    try {
      final svg = await rootBundle.loadString('assets/icons/worker.svg');
      final match = RegExp(r'base64,([^"\s]+)').firstMatch(svg);
      if (match == null) return null;
      final b64 = match.group(1);
      if (b64 == null || b64.isEmpty) return null;
      final pngBytes = base64Decode(b64);

      final codec = await ui.instantiateImageCodec(
        pngBytes,
        targetWidth: targetPx,
        targetHeight: targetPx,
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
      _cachedPixelSize = targetPx;
      return descriptor;
    } on Exception {
      return null;
    }
  }
}
