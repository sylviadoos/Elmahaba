import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/app_settings/locale_theme_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/confirm_dialog.dart';
import 'package:al_mahhaba_school/core/widgets/segmented_control.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/parent_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/profile/presentation/extensions/profile_display.dart';
import 'package:al_mahhaba_school/features/profile/presentation/view_model/profile_event.dart';
import 'package:al_mahhaba_school/features/profile/presentation/view_model/profile_state.dart';
import 'package:al_mahhaba_school/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/delete_account_button.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/log_out_button.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/notification_preferences_sheet.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/profile_card.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/settings_header.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/settings_row.dart';

/// The parent's settings: their profile (which opens it, with their
/// children), language, notifications…, log out and deleting the account.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileViewModel>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileViewModel>()
      ..doAction(const LoadProfileEvent())
      ..doAction(const LoadNotificationsEvent());
  }

  String get _appLanguage => Localizations.localeOf(context).languageCode;

  /// The account's language first; the app follows once it's saved.
  void _changeLanguage(int index) {
    final language = index == 1 ? AppConstants.arKey : AppConstants.enKey;
    if (language == _appLanguage) return;
    context.read<ProfileViewModel>().doAction(ChangeLanguageEvent(language));
  }

  void _loadNotifications() =>
      context.read<ProfileViewModel>().doAction(const LoadNotificationsEvent());

  Future<void> _deleteAccount() async {
    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.deleteAccountTitle,
      message: l10n.deleteAccountMessage,
      confirmLabel: l10n.delete,
    );
    if (!confirmed || !mounted) return;
    context.read<ProfileViewModel>().doAction(const DeleteAccountEvent());
  }

  void _onError(AppException exception) {
    context.showSnackBar(exception.localizedMessage(context), isError: true);
    // Signed out meanwhile (another device deleted the account…).
    if (exception is UnauthorizedException) context.logOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final childrenCount = context.watchChildren().length;
    // The account as the school has it now; the one kept at log in until
    // it loads, or if it can't.
    final profile = context.select(
      (ProfileViewModel viewModel) => viewModel.state.profile.data,
    );
    final parent = context.watchParent();
    final isDeleting = context.select(
      (ProfileViewModel viewModel) =>
          viewModel.state.deletion.state == StateType.loading,
    );
    final notifications = context.select(
      (ProfileViewModel viewModel) => viewModel.state.notifications,
    );
    final preferences = notifications.data;

    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileViewModel, ProfileState>(
          listenWhen: (previous, current) =>
              previous.language != current.language,
          listener: (context, state) => state.language.when(
            initial: () {},
            loading: () {},
            success: (language) {
              if (language != _appLanguage) {
                context.read<LocaleThemeCubit>().changeLocale();
              }
            },
            error: _onError,
          ),
        ),
        BlocListener<ProfileViewModel, ProfileState>(
          listenWhen: (previous, current) =>
              previous.deletion != current.deletion,
          listener: (context, state) => state.deletion.when(
            initial: () {},
            loading: () {},
            success: (_) {
              context.showSnackBar(l10n.accountDeleted);
              // Its token is gone: forget it here too.
              context.logOut();
            },
            error: _onError,
          ),
        ),
        BlocListener<ProfileViewModel, ProfileState>(
          // A change in the sheet that wasn't saved: its switch went back.
          listenWhen: (previous, current) =>
              previous.notifications != current.notifications &&
              current.notifications.state == StateType.error &&
              current.notifications.data != null,
          listener: (context, state) =>
              _onError(state.notifications.exception!),
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SettingsHeader(),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    6.h,
                    20.w,
                    math.max(36.h, bottomInset + 16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 22.h,
                    children: [
                      ProfileCard(
                        name: profile?.displayName(context) ?? parent?.name,
                        phone: profile?.phone ?? parent?.phone,
                        childrenCount: childrenCount,
                        onTap: () =>
                            context.push(AppRoutes.profile, extra: profile),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SettingsRow(
                            icon: AppIcons.globeLanguage,
                            label: l10n.language,
                            trailing: SegmentedControl(
                              expand: false,
                              height: 36,
                              padding: 3,
                              gap: 2,
                              outerRadius: 10,
                              innerRadius: 8,
                              fontSize: 13,
                              options: const [
                                SegmentOption(
                                  'English',
                                  fontFamily: AppFonts.outfit,
                                ),
                                SegmentOption(
                                  'عربي',
                                  fontFamily: AppFonts.cairo,
                                ),
                              ],
                              selected: _appLanguage == AppConstants.arKey
                                  ? 1
                                  : 0,
                              onSelected: _changeLanguage,
                            ),
                          ),
                          SettingsRow(
                            icon: AppIcons.bell,
                            label: l10n.notifications,
                            onTap: preferences == null
                                // Didn't load: tapping tries again.
                                ? notifications.state == StateType.error
                                      ? _loadNotifications
                                      : null
                                // Turned on or off only in there, with
                                // each kind.
                                : () => NotificationPreferencesSheet.show(
                                    context,
                                  ),
                          ),
                          SettingsRow(
                            icon: AppIcons.lock,
                            label: l10n.changePassword,
                            onTap: () => context.push(AppRoutes.changePassword),
                          ),
                          SettingsRow(
                            icon: AppIcons.phone,
                            label: l10n.contactTheSchool,
                            onTap: () => context.push(AppRoutes.contact),
                          ),
                          SettingsRow(
                            icon: AppIcons.info,
                            label: l10n.aboutSchool,
                            onTap: () => context.push(AppRoutes.about),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 6.h,
                        children: [
                          const LogOutButton(),
                          DeleteAccountButton(
                            isLoading: isDeleting,
                            onPressed: _deleteAccount,
                          ),
                        ],
                      ),
                      // Checks Sentry gets errors ("Debug + Sentry" runs
                      // only; never in a release build).
                      if (kDebugMode && AppConfig.sentryEnabled)
                        ElevatedButton(
                          onPressed: () =>
                              throw StateError('This is test exception'),
                          child: const Text('Verify Sentry Setup'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
