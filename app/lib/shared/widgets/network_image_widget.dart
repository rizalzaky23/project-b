import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/dark_theme.dart';

/// Widget gambar dari URL yang kompatibel di Flutter Web dan Mobile.
///
/// - Web: menggunakan [Image.network] dengan header CORS
/// - Mobile: menggunakan [CachedNetworkImage] dengan disk cache
class NetworkImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  Widget get _defaultPlaceholder => Container(
        width: width,
        height: height,
        color: AppTheme.surfaceVariant,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );

  Widget get _defaultError => Container(
        width: width,
        height: height,
        color: AppTheme.surfaceVariant,
        child: const Icon(
          Icons.broken_image_outlined,
          color: AppTheme.textSecondary,
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorWidget ?? _defaultError;
    }

    Widget image;

    if (kIsWeb) {
      // Flutter Web: Image.network dengan header agar bypass CORS
      image = Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        headers: const {
          'Accept': 'image/*',
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _defaultPlaceholder;
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('NetworkImageWidget error loading: $imageUrl — $error');
          return errorWidget ?? _defaultError;
        },
      );
    } else {
      // Mobile: CachedNetworkImage dengan disk cache
      image = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => placeholder ?? _defaultPlaceholder,
        errorWidget: (_, __, ___) => errorWidget ?? _defaultError,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
