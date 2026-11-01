import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/constants/app_constants.dart';

/// App themes. Fonts depend on the language: Montserrat headings and Outfit
/// body text in English, Cairo for everything in Arabic.
///
/// Uses ScreenUtil (`.sp`, `.r`…), so build it below `ScreenUtilScope`.
abstract final class AppTheme {
  static ThemeData light(Locale locale) => _build(Brightness.light, locale);
  static ThemeData dark(Locale locale) => _build(Brightness.dark, locale);

  static ThemeData _build(Brightness brightness, Locale locale) {
    final isDark = brightness == Brightness.dark;
    final isArabic = locale.languageCode == AppConstants.arKey;
    final headingFont = isArabic ? AppFonts.cairo : AppFonts.montserrat;
    final bodyFont = isArabic ? AppFonts.cairo : AppFonts.outfit;
    final background = isDark ? AppColors.darkBackground : AppColors.white;
    final radius = BorderRadius.all(Radius.circular(12.r));

    // Light mode uses the exact design colors; dark mode lets the seed
    // pick readable tones of the brand red.
    final colorScheme = isDark
        ? ColorScheme.fromSeed(
            seedColor: AppColors.mahabbahRed,
            brightness: Brightness.dark,
            secondary: AppColors.gold,
            error: AppColors.error,
          )
        : ColorScheme.fromSeed(
            seedColor: AppColors.mahabbahRed,
            primary: AppColors.mahabbahRed,
            onPrimary: AppColors.white,
            secondary: AppColors.gold,
            onSecondary: AppColors.goldText,
            error: AppColors.error,
            onError: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.ink,
            onSurfaceVariant: AppColors.slate,
            outline: AppColors.mist,
            outlineVariant: AppColors.line,
          );

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    final theme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      // Body font for every text style; headings are swapped in below.
      fontFamily: bodyFont,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        foregroundColor: colorScheme.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? colorScheme.primary : AppColors.actionRed,
          foregroundColor: isDark ? colorScheme.onPrimary : AppColors.white,
          disabledBackgroundColor: isDark ? null : AppColors.line,
          disabledForegroundColor: isDark ? null : AppColors.slate,
          elevation: 0,
          minimumSize: Size(64.w, 56.h),
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.r)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: Size(64.w, 56.h),
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.r)),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.actionRed
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.white),
        side: const BorderSide(color: AppColors.mist, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: isDark ? colorScheme.surfaceContainerHigh : AppColors.white,
        hintStyle: TextStyle(color: isDark ? null : AppColors.placeholder),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: border(colorScheme.outlineVariant),
        enabledBorder: border(colorScheme.outlineVariant),
        focusedBorder: border(colorScheme.primary, 1.5),
        errorBorder: border(colorScheme.error),
        focusedErrorBorder: border(colorScheme.error, 1.5),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? colorScheme.surfaceContainer : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Merged onto the theme's own text styles so they keep their colors.
    return theme.copyWith(
      textTheme: theme.textTheme.merge(
        _typeScale(headingFont: headingFont, bodyFont: bodyFont),
      ),
    );
  }

  /// The design type scale (see the assets README).
  static TextTheme _typeScale({
    required String headingFont,
    required String bodyFont,
  }) {
    TextStyle style(
      String font,
      double size,
      double lineHeight,
      FontWeight weight, {
      double? letterSpacing,
    }) {
      return TextStyle(
        fontFamily: font,
        fontSize: size.sp,
        height: lineHeight / size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
      );
    }

    // Styles not listed here keep Material's sizes with the body font.
    return TextTheme(
      // Display 32/40
      displaySmall: style(headingFont, 32, 40, FontWeight.w800),
      // Onboarding titles 28/34
      headlineMedium: style(
        headingFont,
        28,
        34,
        FontWeight.w800,
        letterSpacing: -0.3,
      ),
      // H1 24/32
      headlineSmall: style(headingFont, 24, 32, FontWeight.w700),
      // H2 18/26
      titleLarge: style(headingFont, 18, 26, FontWeight.w700),
      // Body 16/24
      bodyLarge: style(bodyFont, 16, 24, FontWeight.w400),
      bodyMedium: style(bodyFont, 14, 20, FontWeight.w400),
      // Caption 13/18
      bodySmall: style(bodyFont, 13, 18, FontWeight.w400),
      // Button 16/24
      labelLarge: style(bodyFont, 16, 24, FontWeight.w600),
    );
  }
}
