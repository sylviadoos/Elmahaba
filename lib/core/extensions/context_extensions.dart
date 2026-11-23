import 'package:flutter/material.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/core/widgets/app_toast.dart';
import 'package:al_mahhaba_school/core/widgets/app_toast_type.dart';

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

  /// Puts the keyboard away for good: the field typed in loses its focus,
  /// so the page forgets it. Unfocusing the page's scope instead would
  /// leave the page remembering the field, and a sheet opening and closing
  /// over it (adding a file) would bring the keyboard back.
  void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  /// A short message at the bottom (`AppToast`): gone after a few seconds,
  /// or when closed. Green with a tick, or red with a cross when
  /// [isError] — orange with "!" when it's only that the phone is offline.
  /// [detail] goes in smaller text under it; [type] picks the look itself.
  void showSnackBar(
    String message, {
    bool isError = false,
    String? detail,
    AppToastType? type,
  }) {
    final messenger = ScaffoldMessenger.of(this);
    final offline = isError && message == l10n.noInternet;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppToast(
            title: message,
            detail: detail,
            type:
                type ??
                (offline
                    ? AppToastType.warning
                    : isError
                    ? AppToastType.error
                    : AppToastType.success),
            onClose: messenger.hideCurrentSnackBar,
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
  }
}
