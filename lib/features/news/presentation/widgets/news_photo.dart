import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// A news photo: a URL from the API, or an `assets/` path for the built-in
/// news. Shows a placeholder when the news has no photo, while it loads,
/// and if it can't be loaded.
class NewsPhoto extends StatelessWidget {
  const NewsPhoto(this.source, {super.key, required this.height});

  final String? source;
  final double height;

  @override
  Widget build(BuildContext context) {
    final source = this.source;
    final placeholder = _Placeholder(height: height);
    if (source == null || source.isEmpty) return placeholder;

    // Decode at screen width — the server sends full-size photos.
    final cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .round();

    if (source.startsWith('${AppAssets.images}/')) {
      return Image.asset(
        source,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }

    return Image.network(
      source,
      // Full card width, also inside the fade-in's AnimatedSwitcher.
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: frame == null ? placeholder : child,
        );
      },
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}

/// Light grey area with a faded school logo.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: AppSvgIcon(
        AppImages.logoMarkRed,
        size: 40.r,
        color: AppColors.line,
      ),
    );
  }
}
