import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_router.dart';
import 'package:al_mahhaba_school/config/theme/app_theme.dart';
import 'package:al_mahhaba_school/core/app_settings/locale_theme_cubit.dart';
import 'package:al_mahhaba_school/core/app_settings/locale_theme_state.dart';
import 'package:al_mahhaba_school/core/widgets/screen_util_scope.dart';

class AlMahhabaApp extends StatelessWidget {
  const AlMahhabaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Above MaterialApp so the theme's text sizes can use `.sp`.
    return ScreenUtilScope(
      child: BlocProvider(
        create: (_) => getIt<LocaleThemeCubit>(),
        child: BlocBuilder<LocaleThemeCubit, LocaleThemeState>(
          builder: (context, state) => MaterialApp.router(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(state.locale),
            darkTheme: AppTheme.dark(state.locale),
            themeMode: state.themeMode,
            // Not DevicePreview.locale(context): it would override the
            // language chosen in the app (LocaleThemeCubit) in debug builds.
            locale: state.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: appRouter,
            builder: DevicePreview.appBuilder,
          ),
        ),
      ),
    );
  }
}
