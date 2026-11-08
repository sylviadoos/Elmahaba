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
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/language_button.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/scrollable_fill.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:al_mahhaba_school/core/widgets/red_header_title.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/login_body.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/prompt_link.dart';

/// Parent log in, with a guest option and a link to create an account.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return BlocProvider(
      create: (_) => getIt<AuthViewModel>(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
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
                        const LanguageButton(),
                      ],
                    ),
                    RedHeaderTitle(
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
                        const LoginBody(),
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
      ),
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
