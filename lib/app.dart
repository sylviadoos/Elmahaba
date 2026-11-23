import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_router.dart';
import 'package:al_mahhaba_school/config/theme/app_theme.dart';
import 'package:al_mahhaba_school/core/app_settings/locale_theme_cubit.dart';
import 'package:al_mahhaba_school/core/analytics/session_recorder.dart';
import 'package:al_mahhaba_school/core/app_settings/locale_theme_state.dart';
import 'package:al_mahhaba_school/core/widgets/screen_util_scope.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_bloc.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/widgets/app_status_refresher.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/bloc/app_version_bloc.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/widgets/update_gate.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_state.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/app_icon_badge_sync.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/badge_refresher.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/notification_router.dart';

class AlMahhabaApp extends StatelessWidget {
  const AlMahhabaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Above MaterialApp so the theme's text sizes can use `.sp`.
    return ScreenUtilScope(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<LocaleThemeCubit>()),
          // The signed-in parent and their children, shared by every page
          // (headers, Profile, Add children). Created when first read.
          BlocProvider(create: (_) => getIt<ParentViewModel>()),
          BlocProvider(create: (_) => getIt<ChildrenViewModel>()),
          // The badge on Chat, which the chat updates as it's read.
          BlocProvider(create: (_) => getIt<ChatUnreadBloc>()),
          // Whether visitors get "Log in": asked by the splash for a visitor
          // only, so it's known by the first visitor page; never for a
          // signed-in parent, who uses the app whatever it says.
          BlocProvider(create: (_) => getIt<AppStatusBloc>()),
          // Whether the installed version must or can be updated, asked as
          // the app opens (see `UpdateGate`).
          BlocProvider(create: (_) => getIt<AppVersionBloc>()),
        ],
        // Recorded sessions go by the parent signed in (their id, nothing
        // personal); logging out starts a new one.
        child: BlocListener<ParentViewModel, ParentState>(
          listenWhen: (previous, current) =>
              previous.data?.id != current.data?.id,
          listener: (_, state) {
            final recorder = getIt<SessionRecorder>();
            final parent = state.data;
            parent == null ? recorder.forget() : recorder.identify(parent.id);
          },
          // Under the blocs they refresh, over every page that shows them.
          child: BadgeRefresher(
            child: AppIconBadgeSync(
              child: NotificationRouter(
                child: AppStatusRefresher(
                  child: BlocBuilder<LocaleThemeCubit, LocaleThemeState>(
                    builder: (context, state) => MaterialApp.router(
                      title: AppConfig.appName,
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.light(state.locale),
                      darkTheme: AppTheme.dark(state.locale),
                      themeMode: state.themeMode,
                      // Not DevicePreview.locale(context): it would override the
                      // language chosen in the app (LocaleThemeCubit) in debug
                      // builds.
                      locale: state.locale,
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      routerConfig: appRouter,
                      // Over every page: an update the school forces holds
                      // the whole app back until it's installed.
                      builder: (context, child) => UpdateGate(
                        child: DevicePreview.appBuilder(context, child),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
