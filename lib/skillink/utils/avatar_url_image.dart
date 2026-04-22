import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';

ImageProvider? avatarBackgroundImageProvider(String? url) {
  if (url == null || url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri != null && uri.scheme == 'file') {
    return FileImage(File.fromUri(uri));
  }
  if (url.startsWith('https://') || url.startsWith('http://')) {
    return NetworkImage(url);
  }
  return null;
}

Widget accountAvatarSquare(String url, {required double size}) {
  final uri = Uri.tryParse(url);
  if (uri != null && uri.scheme == 'file') {
    return Image.file(
      File.fromUri(uri),
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, _) => Icon(
        Icons.person,
        size: size * 0.5,
        color: AppColors.textMuted,
      ),
    );
  }
  return CachedNetworkImage(
    imageUrl: url,
    width: size,
    height: size,
    fit: BoxFit.cover,
    errorWidget: (context, url, _) => Icon(
      Icons.person,
      size: size * 0.5,
      color: AppColors.textMuted,
    ),
  );
}

class RoundAvatar extends StatelessWidget {
  const RoundAvatar({
    super.key,
    required this.url,
    required this.radius,
    this.pickedFile,
    this.backgroundColor,
    this.placeholder,
    this.placeholderIconSize,
  });

  final String? url;
  final double radius;
  final File? pickedFile;
  final Color? backgroundColor;
  final Widget? placeholder;
  final double? placeholderIconSize;

  double get _size => radius * 2;

  Widget _fallback() {
    final bg = backgroundColor ?? AppColors.shimmerBase;
    return Container(
      width: _size,
      height: _size,
      color: bg,
      alignment: Alignment.center,
      child: placeholder ??
          Icon(
            Icons.person,
            size: placeholderIconSize ?? radius,
            color: AppColors.textMuted,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pickedFile != null) {
      return ClipOval(
        child: Image.file(
          pickedFile!,
          width: _size,
          height: _size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }

    final raw = url?.trim();
    if (raw == null || raw.isEmpty) {
      return ClipOval(child: _fallback());
    }

    final uri = Uri.tryParse(raw);
    if (uri != null && uri.scheme == 'file') {
      return ClipOval(
        child: Image.file(
          File.fromUri(uri),
          width: _size,
          height: _size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }

    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      return ClipOval(child: _fallback());
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: raw,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        placeholder: (_, _) => _fallback(),
        errorWidget: (_, _, _) => _fallback(),
      ),
    );
  }
}
