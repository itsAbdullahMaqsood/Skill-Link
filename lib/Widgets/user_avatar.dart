import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skilllink/services/api_service.dart';

const String _kDefaultAvatarAsset = 'assets/images/default_user_avatar.svg';

class UserAvatar extends StatelessWidget {
  final String? imageRef;
  final double radius;
  final Color backgroundColor;

  const UserAvatar({
    super.key,
    required this.imageRef,
    this.radius = 24,
    this.backgroundColor = const Color(0xFFE0E0E0),
  });

  String? get _resolvedUrl {
    final raw = imageRef?.trim();
    if (raw == null || raw.isEmpty) return null;

    final httpIndex = raw.indexOf('http://');
    final httpsIndex = raw.indexOf('https://');
    final embeddedIndex = httpIndex == -1
        ? httpsIndex
        : (httpsIndex == -1 ? httpIndex : (httpIndex < httpsIndex ? httpIndex : httpsIndex));
    if (embeddedIndex > 0) {
      return raw.substring(embeddedIndex);
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('//')) return 'https:$raw';
    if (raw.startsWith('/')) return '${ApiService.activeAssetBaseUrl}$raw';
    return '${ApiService.activeAssetBaseUrl}/$raw';
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;
    final size = radius * 2;

    if (url == null) {
      return _placeholder();
    }

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return ColoredBox(
              color: backgroundColor,
              child: Center(
                child: SizedBox(
                  width: radius * 0.85,
                  height: radius * 0.85,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Padding(
        padding: EdgeInsets.all(radius * 0.2),
        child: SvgPicture.asset(
          _kDefaultAvatarAsset,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => Icon(
            Icons.person_rounded,
            size: radius * 1.15,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
