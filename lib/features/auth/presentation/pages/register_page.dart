import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_checkbox.dart';
import 'package:al_mahhaba_school/core/widgets/app_text_field.dart';
import 'package:al_mahhaba_school/core/widgets/country_code_prefix.dart';
import 'package:al_mahhaba_school/core/widgets/scrollable_fill.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/prompt_link.dart';

/// Parent sign-up: name, mobile, email, password and terms.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _agreed = false;

  void _backToLogin() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final padding = MediaQuery.paddingOf(context);
    final linkStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.actionRed,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: ScrollableFill(
          padding: EdgeInsets.fromLTRB(
            24.w,
            padding.top + 8.h,
            24.w,
            math.max(28.h, padding.bottom + 12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 18.h,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppBackButton(
                    style: AppBackButtonStyle.onLight,
                    fallbackRoute: AppRoutes.login,
                  ),
                  SvgPicture.asset(
                    AppImages.logoMarkRed,
                    width: 46.r,
                    height: 33.r,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.h,
                children: [
                  Text(
                    l10n.createAccount,
                    style: textTheme.headlineMedium?.copyWith(letterSpacing: 0),
                  ),
                  Text(
                    l10n.registerSubtitle,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 15.sp,
                      height: 22 / 15,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12.h,
                children: [
                  AppTextField(
                    label: l10n.parentFullName,
                    hint: l10n.asOnNationalId,
                    height: 52,
                    labelGap: 6,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                  ),
                  AppTextField(
                    label: l10n.mobileNumber,
                    hint: l10n.phoneHint,
                    height: 52,
                    labelGap: 6,
                    prefix: const CountryCodePrefix(),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.telephoneNumberNational,
                    ],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  AppTextField(
                    label: l10n.email,
                    hint: l10n.emailHint,
                    height: 52,
                    labelGap: 6,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                  ),
                  AppTextField(
                    label: l10n.password,
                    hint: l10n.passwordHint,
                    height: 52,
                    labelGap: 6,
                    isPassword: true,
                    showPasswordToggle: false,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                  ),
                  AppCheckbox(
                    value: _agreed,
                    onChanged: (value) => setState(() => _agreed = value),
                    label: Text.rich(
                      TextSpan(
                        text: l10n.agreePrefix,
                        children: [
                          // TODO: open the Terms / Privacy Policy pages.
                          TextSpan(text: l10n.terms, style: linkStyle),
                          TextSpan(text: l10n.agreeAnd),
                          TextSpan(text: l10n.privacyPolicy, style: linkStyle),
                        ],
                      ),
                    ),
                  ),
                  AppButton(
                    label: l10n.createAccount,
                    // TODO: create the account (Cubit) before verifying.
                    onPressed: () => context.push(AppRoutes.otp),
                  ),
                ],
              ),
              const Spacer(),
              PromptLink(
                prompt: l10n.alreadyHaveAccount,
                action: l10n.login,
                onTap: _backToLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
