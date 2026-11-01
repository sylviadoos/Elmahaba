import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/app_settings/locale_theme_state.dart';
import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/core/storage/shared_pref_helper.dart';

/// App language and theme, saved so they survive restarts.
@injectable
class LocaleThemeCubit extends Cubit<LocaleThemeState> {
  final SharedPrefHelper sharedPrefHelper;

  LocaleThemeCubit(this.sharedPrefHelper)
    : super(
        LocaleThemeState(
          locale: Locale(
            sharedPrefHelper.getString(AppConstants.languageCode) ??
                AppConstants.enKey,
          ),
          themeMode:
              ThemeMode.values.asNameMap()[sharedPrefHelper.getString(
                AppConstants.themeMode,
              )] ??
              // The design is light only, so ignore the phone's dark mode
              // unless the user picks a theme in the app.
              ThemeMode.light,
        ),
      );

  /// Switches between Arabic and English.
  void changeLocale() {
    final newLocale = state.locale.languageCode == AppConstants.enKey
        ? AppConstants.arKey
        : AppConstants.enKey;

    sharedPrefHelper.saveString(
      key: AppConstants.languageCode,
      value: newLocale,
    );
    emit(state.copyWith(locale: Locale(newLocale)));
  }

  /// `ThemeMode.system` follows the phone's light/dark setting.
  void setThemeMode(ThemeMode mode) {
    sharedPrefHelper.saveString(key: AppConstants.themeMode, value: mode.name);
    emit(state.copyWith(themeMode: mode));
  }
}
