import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageViewerScreen extends StatelessWidget {
  const ImageViewerScreen({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: _imageWidget(url),
        ),
      ),
    );
  }

  static Widget _imageWidget(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        placeholder: (_, _) => const CircularProgressIndicator(color: Colors.white),
        errorWidget: (_, _, _) =>
            const Icon(Icons.broken_image_outlined, color: Colors.white, size: 64),
      );
    }
    if (url.startsWith('file://')) {
      return Image.file(File(Uri.parse(url).toFilePath()), fit: BoxFit.contain);
    }
    return Image.file(File(url), fit: BoxFit.contain);
  }
}
