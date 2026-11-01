import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/app_settings/locale_theme_cubit.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_checkbox.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/app_text_field.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/scrollable_fill.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/auth_header_title.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/prompt_link.dart';

/// Parent log in, with a guest option and a link to create an account.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.mahabbahRed,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RedHeader(
              horizontalPadding: 24,
              bottomPadding: 36,
              watermarkTop: 74,
              watermarkSize: const Size(250, 178),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 18.h,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        AppImages.logoMarkWhite,
                        width: 56.r,
                        height: 40.r,
                      ),
                      const _LanguageButton(),
                    ],
                  ),
                  AuthHeaderTitle(
                    title: l10n.welcomeBack,
                    subtitle: l10n.loginSubtitle,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.white,
                child: ScrollableFill(
                  padding: EdgeInsets.fromLTRB(
                    24.w,
                    30.h,
                    24.w,
                    math.max(36.h, bottomInset + 16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 18.h,
                    children: [
                      AppTextField(
                        label: l10n.emailOrMobile,
                        hint: l10n.emailHint,
                        prefixIcon: AppIcons.user,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                      ),
                      AppTextField(
                        label: l10n.password,
                        hint: l10n.enterYourPassword,
                        prefixIcon: AppIcons.lock,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: AppCheckbox(
                              value: _rememberMe,
                              onChanged: (value) =>
                                  setState(() => _rememberMe = value),
                              label: Text(l10n.rememberMe),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: forgot password flow (no design yet).
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.actionRed,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              textStyle: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Text(l10n.forgotPasswordQuestion),
                          ),
                        ],
                      ),
                      AppButton(
                        label: l10n.login,
                        // TODO: authenticate (Cubit) before opening Home.
                        onPressed: () => context.go(AppRoutes.home),
                        trailingIcon: AppSvgIcon(
                          AppIcons.arrowRight,
                          size: 20.r,
                          matchTextDirection: true,
                        ),
                      ),
                      const _OrDivider(),
                      AppButton(
                        label: l10n.continueAsGuest,
                        outlined: true,
                        onPressed: () => context.go(AppRoutes.explore),
                      ),
                      const Spacer(),
                      PromptLink(
                        prompt: l10n.newParent,
                        action: l10n.createAnAccount,
                        onTap: () => context.push(AppRoutes.register),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Switches the app to the other language; the label is written in that
/// language ("عربي" / "English").
class _LanguageButton extends StatelessWidget {
  const _LanguageButton();

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return OutlinedButton(
      onPressed: () => context.read<LocaleThemeCubit>().changeLocale(),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.white,
        minimumSize: Size(0, 44.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        side: BorderSide(color: AppColors.white.withValues(alpha: 0.4)),
        shape: const StadiumBorder(),
        textStyle: TextStyle(
          fontFamily: isArabic ? AppFonts.outfit : AppFonts.cairo,
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(context.l10n.otherLanguage),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12.w,
      children: [
        const Expanded(child: Divider(height: 1, color: AppColors.line)),
        Text(
          context.l10n.or,
          style: context.textTheme.bodySmall?.copyWith(color: AppColors.slate),
        ),
        const Expanded(child: Divider(height: 1, color: AppColors.line)),
      ],
    );
  }
}
