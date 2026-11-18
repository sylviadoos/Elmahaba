import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:al_mahhaba_school/app.dart';
import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_router.dart';
import 'package:al_mahhaba_school/core/analytics/session_recorder.dart';
import 'package:al_mahhaba_school/core/analytics/session_recording.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/core/utils/app_bloc_observer.dart';
import 'package:al_mahhaba_school/core/utils/temp_files.dart';
import 'package:al_mahhaba_school/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait only: the screens are designed for a phone held upright.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Crashlytics first: Sentry, started after it, hands each error on to it.
  await _reportCrashes();
  await configureDependencies();
  Bloc.observer = AppBlocObserver();
  _reportScreens(getIt<SessionRecorder>());
  await _runReportingToSentry(
    // Session recordings and heatmaps (Microsoft Clarity, Android and iOS),
    // content masked; release builds only unless asked for.
    SessionRecording(
      // Preview on other phone sizes while developing on a computer
      // (Windows, web); never in release builds. Not on a phone or
      // emulator: there it shrinks the app above its toolbar, which leaves
      // a white gap over the keyboard.
      app: DevicePreview(
        enabled:
            kDebugMode &&
            defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS,
        builder: (context) => const AlMahhabaApp(),
      ),
    ),
  );
  // After the first frame: it waits on the parent allowing notifications.
  unawaited(getIt<NotificationService>().init());
  unawaited(TempFiles.clean());
}

/// Tells the session recording which screen is on show, by its route, each
/// time it changes (a tab picked, a page opened or closed).
void _reportScreens(SessionRecorder recorder) {
  if (!recorder.isEnabled) return;
  final delegate = appRouter.routerDelegate;
  delegate.addListener(() {
    if (delegate.currentConfiguration.isEmpty) return;
    final state = appRouter.state;
    recorder.showScreen(state.fullPath ?? state.uri.path);
  });
}

/// Runs [app], sending uncaught errors to Sentry as well as Crashlytics:
/// Sentry keeps the handlers [_reportCrashes] set and calls them after it.
/// Nothing personal goes: no IP addresses, no screenshots (children's data
/// is on screen). Just runs [app] while Sentry is off.
Future<void> _runReportingToSentry(Widget app) async {
  if (!AppConfig.sentryEnabled) return runApp(app);
  await SentryFlutter.init(
    (options) => options
      ..dsn = AppConfig.sentryDsn
      // Debug runs apart, to filter out on the dashboard.
      ..environment = kDebugMode ? 'debug' : AppConfig.environment.name
      ..sendDefaultPii = false
      ..attachScreenshot = false
      // How long screens and requests take, for a fifth of sessions.
      ..tracesSampleRate = 0.2,
    // Follows taps, for what led to an error.
    appRunner: () => runApp(SentryWidget(child: app)),
  );
}

/// Sends uncaught Flutter and Dart errors to Firebase Crashlytics, so the
/// school hears about crashes on parents' phones. Debug runs report to the
/// console only; a developer's own crashes aren't the school's problem.
Future<void> _reportCrashes() async {
  // Crashlytics has no web version; Sentry covers the web.
  if (kIsWeb) return;
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  if (kDebugMode) return;

  FlutterError.onError = crashlytics.recordFlutterFatalError;
  // Errors outside Flutter's own callbacks, e.g. in a bare async gap.
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };
}
