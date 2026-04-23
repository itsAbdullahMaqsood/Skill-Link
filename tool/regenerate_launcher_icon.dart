// Recolors assets/images/app_icon_launcher.png background to match
// AppColors.primary (#1E3A8A) while preserving near-white icon strokes.
//
// Run from repo root: dart run tool/regenerate_launcher_icon.dart

import 'dart:io';

import 'package:image/image.dart' as img;

const _brandR = 0x1E;
const _brandG = 0x3A;
const _brandB = 0x8A;

bool _keepAsIconPixel(int r, int g, int b) =>
    r > 195 && g > 200 && b > 205;

void main() {
  final path = File('assets/images/app_icon_launcher.png');
  if (!path.existsSync()) {
    stderr.writeln('Missing ${path.path}');
    exitCode = 1;
    return;
  }

  final image = img.decodePng(path.readAsBytesSync());
  if (image == null) {
    stderr.writeln('Could not decode PNG');
    exitCode = 1;
    return;
  }

  final hasAlpha = image.numChannels == 4;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final p = image.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      if (_keepAsIconPixel(r, g, b)) continue;

      final a = p.a.toInt();
      if (hasAlpha) {
        image.setPixelRgba(x, y, _brandR, _brandG, _brandB, a);
      } else {
        image.setPixelRgb(x, y, _brandR, _brandG, _brandB);
      }
    }
  }

  path.writeAsBytesSync(img.encodePng(image));
  stdout.writeln('Updated ${path.path} with brand blue #1E3A8A');
}
