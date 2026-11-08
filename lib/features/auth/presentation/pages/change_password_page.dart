import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_text_field.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/change_password_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/auth_field_errors.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_state.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/password_changed_card.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/password_rules.dart';

/// Profile's "Change password": the current password, then the new one
/// typed twice and checked against the rules as it's typed.
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthViewModel>(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmation = TextEditingController();

  /// The server's field errors (`current_password`, `password`,
  /// `password_confirmation`), shown until the fields are edited.
  Map<String, String> _serverErrors = const {};

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    context.read<AuthViewModel>().doAction(
      ChangePasswordEvent(
        ChangePasswordRequestEntity(
          currentPassword: _current.text,
          password: _password.text,
          passwordConfirmation: _confirmation.text,
        ),
      ),
    );
  }

  void _backToSettings() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.settings);

  void _onError(BuildContext context, AppException exception) {
    // Signed out meanwhile (another device changed the password…).
    if (exception is UnauthorizedException) {
      context.showSnackBar(exception.localizedMessage(context), isError: true);
      context.logOut();
      return;
    }

    final fieldErrors = switch (exception) {
      // Comes without `errors`: it's about the current password.
      ServerException(
        code: AuthErrorCodes.currentPasswordIncorrect,
        :final message?,
      ) =>
        {'current_password': message},
      _ => exception.authFieldErrors,
    };
    if (fieldErrors.isEmpty) {
      context.showSnackBar(exception.localizedMessage(context), isError: true);
      return;
    }
    setState(() => _serverErrors = fieldErrors);
    context.showSnackBar(context.l10n.checkHighlightedFields, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final current = _current.text;
    final password = _password.text;
    final confirmation = _confirmation.text;
    final mismatch = confirmation.isNotEmpty && confirmation != password;
    final canSave =
        current.isNotEmpty &&
        PasswordRule.allMet(password, confirmation, current: current);

    AppTextField passwordField({
      required TextEditingController controller,
      required String label,
      required String hint,
      required TextInputAction action,
      required Iterable<String> autofillHints,
      String? errorText,
    }) => AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      prefixIcon: AppIcons.lock,
      isPassword: true,
      errorText: errorText,
      textInputAction: action,
      autofillHints: autofillHints,
      // The rules follow what's typed; the server's errors go.
      onChanged: (_) => setState(() => _serverErrors = const {}),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RedHeader(
              horizontalPadding: 16,
              bottomPadding: 40,
              watermarkTop: 20,
              watermarkSize: const Size(200, 143),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10.h,
                children: [
                  Row(
                    spacing: 10.w,
                    children: [
                      const AppBackButton(fallbackRoute: AppRoutes.settings),
                      Expanded(
                        child: Text(
                          l10n.changePassword,
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 24.sp,
                            height: 1.25,
                            letterSpacing: 0,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    l10n.changePasswordSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      height: 20 / 14,
                      color: AppColors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  8.h,
                  20.w,
                  math.max(40.h, bottomInset + 16),
                ),
                child: BlocConsumer<AuthViewModel, AuthState>(
                  listenWhen: (_, state) => state.state == StateType.error,
                  listener: (context, state) =>
                      _onError(context, state.exception!),
                  builder: (context, state) {
                    if (state.data is PasswordChanged) {
                      return PasswordChangedCard(
                        title: l10n.passwordUpdated,
                        message: l10n.useNewPasswordNextTime,
                        actionLabel: l10n.backToSettings,
                        onAction: _backToSettings,
                      );
                    }

                    return AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 18.h,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 8.h,
                            children: [
                              passwordField(
                                controller: _current,
                                label: l10n.currentPassword,
                                hint: l10n.enterCurrentPassword,
                                action: TextInputAction.next,
                                autofillHints: const [AutofillHints.password],
                                errorText: _serverErrors['current_password'],
                              ),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: TextButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.forgotPassword),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.actionRed,
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 6.h,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    textStyle: textTheme.bodySmall?.copyWith(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: Text(l10n.forgotCurrentPassword),
                                ),
                              ),
                            ],
                          ),
                          passwordField(
                            controller: _password,
                            label: l10n.newPassword,
                            hint: l10n.enterNewPassword,
                            action: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            errorText: _serverErrors['password'],
                          ),
                          passwordField(
                            controller: _confirmation,
                            label: l10n.confirmNewPassword,
                            hint: l10n.typeItAgain,
                            action: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            errorText: mismatch
                                ? l10n.passwordsDoNotMatch
                                : _serverErrors['password_confirmation'],
                          ),
                          PasswordRules(
                            password: password,
                            confirmation: confirmation,
                            currentPassword: current,
                          ),
                          AppButton(
                            label: l10n.saveNewPassword,
                            isLoading: state.state == StateType.loading,
                            onPressed: canSave ? _save : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
