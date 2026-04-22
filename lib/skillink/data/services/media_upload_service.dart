import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:skilllink/skillink/utils/result.dart';

class MediaUploadService {
  MediaUploadService();

  Future<Result<String>> uploadBytes({
    required String storagePath,
    required Uint8List bytes,
    required String contentType,
    void Function(double progress)? onProgress,
  }) async {
    if (kDebugMode) {
      debugPrint(
        'MediaUploadService.uploadBytes is a no-op stub (path=$storagePath, '
        'contentType=$contentType, bytes=${bytes.length}).',
      );
    }
    return Failure(
      'Media uploads are temporarily disabled while the new SkillLink backend '
      'is being wired up.',
    );
  }

  Future<Result<String>> uploadFile({
    required String storagePath,
    required File file,
    required String contentType,
    void Function(double progress)? onProgress,
  }) async {
    if (kDebugMode) {
      debugPrint(
        'MediaUploadService.uploadFile is a no-op stub (path=$storagePath, '
        'contentType=$contentType, file=${file.path}).',
      );
    }
    return Failure(
      'Media uploads are temporarily disabled while the new SkillLink backend '
      'is being wired up.',
    );
  }
}
