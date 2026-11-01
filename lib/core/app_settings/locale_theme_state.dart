import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LocaleThemeState extends Equatable {
  final Locale locale;
  final ThemeMode themeMode;

  const LocaleThemeState({required this.locale, required this.themeMode});

  LocaleThemeState copyWith({Locale? locale, ThemeMode? themeMode}) {
    return LocaleThemeState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [locale, themeMode];
}
