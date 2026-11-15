import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/profile/presentation/view_model/profile_event.dart';
import 'package:al_mahhaba_school/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/settings_row.dart';

/// "Notifications" from Settings: the master switch, then a switch for
/// each kind the school sends (off while the master one is). Each change
/// is saved at once, on Settings' [ProfileViewModel].
class NotificationPreferencesSheet extends StatelessWidget {
  const NotificationPreferencesSheet({super.key});

  /// Over Settings, sharing its view model.
  static Future<void> show(BuildContext context) {
    final viewModel = context.read<ProfileViewModel>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      barrierColor: AppColors.scrim,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: viewModel,
        child: const NotificationPreferencesSheet(),
      ),
    );
  }

  /// The icon and name of a kind; one the app doesn't know yet shows as
  /// the school names it.
  static (String, String) _kind(BuildContext context, String category) {
    final l10n = context.l10n;
    return switch (category) {
      'attendance' => (AppIcons.calendarPresent, l10n.attendance),
      'announcements' => (AppIcons.megaphoneGeneral, l10n.announcements),
      'homework' => (AppIcons.book, l10n.homework),
      'results' => (AppIcons.navResults, l10n.results),
      'fees' => (AppIcons.navFees, l10n.fees),
      'messages' => (AppIcons.navChat, l10n.messages),
      _ => (AppIcons.bell, category),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final notifications = context.select(
      (ProfileViewModel viewModel) => viewModel.state.notifications,
    );
    // Opened once they loaded.
    final preferences = notifications.data;
    if (preferences == null) return const SizedBox.shrink();
    // One change at a time.
    final saving = notifications.state == StateType.loading;
    final error = notifications.state == StateType.error
        ? notifications.exception?.localizedMessage(context)
        : null;

    void set(ProfileEvent event) =>
        context.read<ProfileViewModel>().doAction(event);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        math.max(30.h, MediaQuery.paddingOf(context).bottom + 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.handle,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 16.h, 4.w, 6.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4.h,
              children: [
                Text(
                  l10n.notifications,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 18.sp,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  l10n.notificationKindsHint,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 13.sp,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsRow(
                    icon: AppIcons.bell,
                    label: l10n.notifications,
                    trailing: Switch(
                      value: preferences.pushEnabled,
                      onChanged: saving
                          ? null
                          : (on) => set(SetNotificationsEvent(on: on)),
                    ),
                  ),
                  if (!preferences.pushEnabled)
                    Padding(
                      padding: EdgeInsets.only(top: 10.h),
                      child: Text(
                        l10n.notificationsOffNote,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.slate,
                        ),
                      ),
                    ),
                  for (final MapEntry(key: category, value: on)
                      in preferences.categories.entries)
                    Builder(
                      builder: (context) {
                        final (icon, label) = _kind(context, category);
                        return SettingsRow(
                          icon: icon,
                          label: label,
                          trailing: Switch(
                            value: on,
                            onChanged: saving || !preferences.pushEnabled
                                ? null
                                : (on) => set(
                                    SetNotificationCategoryEvent(
                                      category,
                                      on: on,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          if (error != null)
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Text(
                error,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
