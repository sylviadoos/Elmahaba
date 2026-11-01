import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/app_settings/locale_theme_cubit.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/dashed_border.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/section_title.dart';
import 'package:al_mahhaba_school/core/widgets/segmented_control.dart';
import 'package:al_mahhaba_school/features/children/data/mock_children.dart';
import 'package:al_mahhaba_school/features/children/data/models/child_profile.dart';

/// Parent profile: children, settings (language, notifications…) and
/// log out.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // TODO: save with the notification settings API.
  bool _chatNotifications = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isArabic =
        Localizations.localeOf(context).languageCode == AppConstants.arKey;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _ProfileHeader(),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10.h,
                      children: [
                        SectionTitle(l10n.myChildren),
                        for (final child in mockChildren) _ChildRow(child),
                        const _AddChildButton(),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionTitle(l10n.settings),
                        SizedBox(height: 6.h),
                        _SettingsRow(
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
                              SegmentOption('عربي', fontFamily: AppFonts.cairo),
                            ],
                            selected: isArabic ? 1 : 0,
                            onSelected: (_) =>
                                context.read<LocaleThemeCubit>().changeLocale(),
                          ),
                        ),
                        _SettingsRow(
                          icon: AppIcons.bell,
                          label: l10n.chatNotifications,
                          onTap: () => setState(
                            () => _chatNotifications = !_chatNotifications,
                          ),
                          trailing: SizedBox.square(
                            dimension: 22.r,
                            child: Checkbox(
                              value: _chatNotifications,
                              onChanged: (value) => setState(
                                () => _chatNotifications = value ?? false,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                        _SettingsRow(
                          icon: AppIcons.lock,
                          label: l10n.changePassword,
                          // TODO: change password flow (no design yet).
                          onTap: () {},
                        ),
                        _SettingsRow(
                          icon: AppIcons.phone,
                          label: l10n.contactTheSchool,
                          onTap: () => context.push(AppRoutes.contact),
                        ),
                        _SettingsRow(
                          icon: AppIcons.info,
                          label: l10n.aboutSchool,
                          onTap: () => context.push(AppRoutes.about),
                        ),
                      ],
                    ),
                    Material(
                      color: AppColors.blush,
                      borderRadius: BorderRadius.circular(16.r),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        // TODO: clear the session (Cubit) before leaving.
                        onTap: () => context.go(AppRoutes.login),
                        child: SizedBox(
                          height: 52.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 8.w,
                            children: [
                              AppSvgIcon(
                                AppIcons.logOut,
                                size: 18.r,
                                color: AppColors.mahabbahRed,
                                matchTextDirection: true,
                              ),
                              Text(
                                l10n.logout,
                                style: context.textTheme.labelLarge?.copyWith(
                                  fontSize: 15.sp,
                                  color: AppColors.mahabbahRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final soft = textTheme.bodyMedium?.copyWith(
      color: AppColors.white.withValues(alpha: 0.88),
    );

    return RedHeader(
      horizontalPadding: 16,
      bottomPadding: 44,
      watermarkTop: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16.h,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppBackButton(fallbackRoute: AppRoutes.home),
              Text(
                l10n.profile,
                style: textTheme.titleLarge?.copyWith(color: AppColors.white),
              ),
              IconButton(
                // TODO: edit profile (no design yet).
                onPressed: () {},
                tooltip: l10n.editProfile,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.white.withValues(alpha: 0.16),
                  fixedSize: Size.square(44.r),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: AppSvgIcon(
                  AppIcons.edit,
                  size: 18.r,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          Row(
            spacing: 14.w,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  mockParentInitials,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 22.sp,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mahabbahRed,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2.h,
                  children: [
                    Text(
                      mockParentName,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 20.sp,
                        height: 1.25,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      mockParentPhone,
                      textDirection: TextDirection.ltr,
                      style: soft,
                    ),
                    Text(
                      mockParentEmail,
                      textDirection: TextDirection.ltr,
                      style: soft,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChildRow extends StatelessWidget {
  const _ChildRow(this.child);

  final ChildProfile child;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        // TODO: open the child's details (no design yet).
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            spacing: 12.w,
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.blush,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  child.fullName.characters.first,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 17.sp,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mahabbahRed,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2.h,
                  children: [
                    Text(
                      child.fullName,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 15.sp,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${child.grade} · ${context.l10n.childIdTail(child.idTail)}',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
              AppSvgIcon(
                AppIcons.chevronRight,
                size: 18.r,
                color: AppColors.mist,
                matchTextDirection: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddChildButton extends StatelessWidget {
  const _AddChildButton();

  @override
  Widget build(BuildContext context) {
    final radius = 14.r;

    return DashedBorder(
      radius: radius,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(AppRoutes.addChildren),
          child: SizedBox(
            height: 48.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8.w,
              children: [
                AppSvgIcon(
                  AppIcons.plus,
                  size: 16.r,
                  color: AppColors.actionRed,
                ),
                Text(
                  context.l10n.addAChild,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.actionRed,
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

/// Settings line: icon tile, label and a [trailing] control (a chevron by
/// default).
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  final String icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          spacing: 12.w,
          children: [
            IconBox(
              icon,
              size: 38.r,
              iconSize: 18.r,
              radius: 12.r,
              background: AppColors.surface,
            ),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: 15.sp,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                AppSvgIcon(
                  AppIcons.chevronRight,
                  size: 18.r,
                  color: AppColors.mist,
                  matchTextDirection: true,
                ),
          ],
        ),
      ),
    );
  }
}
