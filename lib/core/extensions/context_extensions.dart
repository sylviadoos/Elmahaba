import 'package:flutter/material.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';

extension ContextExtensions on BuildContext {
  /// Translated texts: `context.l10n.login`.
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  void hideKeyboard() => FocusScope.of(this).unfocus();

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colors.error : null,
        ),
      );
  }
}
