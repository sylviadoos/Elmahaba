import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/theme/app_theme.dart';
import 'package:al_mahhaba_school/core/widgets/screen_util_scope.dart';

/// The app around a widget test's pages, as `app.dart` builds it:
/// ScreenUtil, the theme and the translations, with [router]'s pages and
/// the view models in [providers] above them.
class TestApp extends StatelessWidget {
  const TestApp({
    super.key,
    required this.router,
    this.providers = const [],
    this.locale = const Locale('en'),
  });

  final GoRouter router;
  final List<BlocProvider> providers;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    // Built under ScreenUtilScope: the theme's sizes use `.r` and `.sp`.
    final app = Builder(
      builder: (_) => MaterialApp.router(
        theme: AppTheme.light(locale),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );

    return ScreenUtilScope(
      child: providers.isEmpty
          ? app
          : MultiBlocProvider(providers: providers, child: app),
    );
  }
}

extension PhoneScreen on WidgetTester {
  /// The design's phone (390 × 844 at 3x) instead of the 800 × 600 test
  /// window, until the test ends.
  void usePhoneScreen() {
    view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(view.reset);
  }
}
