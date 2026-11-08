import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/app.dart';
import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/core/utils/app_bloc_observer.dart';
import 'package:al_mahhaba_school/core/utils/temp_files.dart';
import 'package:al_mahhaba_school/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  Bloc.observer = AppBlocObserver();
  runApp(
    // Preview on other phone sizes while developing on a computer (Windows,
    // web); never in release builds. Not on a phone or emulator: there it
    // shrinks the app above its toolbar, which leaves a white gap over the
    // keyboard.
    DevicePreview(
      enabled:
          kDebugMode &&
          defaultTargetPlatform != TargetPlatform.android &&
          defaultTargetPlatform != TargetPlatform.iOS,
      builder: (context) => const AlMahhabaApp(),
    ),
  );
  // After the first frame: it waits on the parent allowing notifications.
  unawaited(getIt<NotificationService>().init());
  unawaited(TempFiles.clean());
}
