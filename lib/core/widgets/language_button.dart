import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/app_settings/locale_theme_cubit.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

enum LanguageButtonStyle {
  /// See-through white outline, for the red headers.
  onRed,

  /// Solid white, like Skip on the onboarding's pink.
  onPink,
}

/// Switches the app to the other language; the label is written in that
/// language ("عربي" / "English").
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key, this.style = LanguageButtonStyle.onRed});

  final LanguageButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final onPink = style == LanguageButtonStyle.onPink;

    return OutlinedButton(
      onPressed: () => context.read<LocaleThemeCubit>().changeLocale(),
      style: OutlinedButton.styleFrom(
        foregroundColor: onPink ? AppColors.ink : AppColors.white,
        backgroundColor: onPink ? AppColors.white : null,
        minimumSize: Size(0, 44.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        side: onPink
            ? BorderSide.none
            : BorderSide(color: AppColors.white.withValues(alpha: 0.4)),
        shape: const StadiumBorder(),
        textStyle: TextStyle(
          fontFamily: isArabic ? AppFonts.outfit : AppFonts.cairo,
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(context.l10n.otherLanguage),
    );
  }
}
