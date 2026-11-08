import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/scrollable_fill.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/auth_field_errors.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_state.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/prompt_link.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/register_form.dart';

/// Parent sign-up: mobile, password (typed twice) and terms.
///
/// No name or email — the school already has them for registered numbers.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final padding = MediaQuery.paddingOf(context);

    return BlocProvider(
      create: (_) => getIt<AuthViewModel>(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                      style: textTheme.headlineMedium?.copyWith(
                        letterSpacing: 0,
                      ),
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
                const _RegisterBody(),
                const Spacer(),
                PromptLink(
                  prompt: l10n.alreadyHaveAccount,
                  action: l10n.login,
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterBody extends StatelessWidget {
  const _RegisterBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthViewModel, AuthState>(
      listenWhen: (_, state) =>
          state.state == StateType.success || state.state == StateType.error,
      listener: (context, state) {
        final l10n = context.l10n;
        if (state.data case final PhoneEligible eligible) {
          if (eligible.eligibility.alreadyRegistered) {
            context.showSnackBar(l10n.accountAlreadyExists, isError: true);
            return;
          }
          context.push(AppRoutes.otp, extra: eligible);
          return;
        }

        // TODO: a "contact the school" sheet (school_contact) for
        // registration_not_eligible — its message shows here for now.
        final exception = state.exception!;
        context.showSnackBar(
          exception.authFieldErrors.isNotEmpty
              ? l10n.checkHighlightedFields
              : exception.localizedMessage(context),
          isError: true,
        );
      },
      builder: (context, state) => RegisterForm(
        isSending: state.state == StateType.loading,
        serverErrors: state.exception.authFieldErrors,
        onSubmit: (request) => context.read<AuthViewModel>().doAction(
          CheckRegisterPhoneEvent(request),
        ),
      ),
    );
  }
}
