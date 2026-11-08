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
import 'package:al_mahhaba_school/core/widgets/red_header_title.dart';
import 'package:al_mahhaba_school/core/widgets/scrollable_fill.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/reset_password_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/auth_field_errors.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_state.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/password_changed_card.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/password_rules.dart';

/// Forgot password, step 3: the new password, typed twice and checked
/// against the rules as it's typed; then "Password changed".
class NewPasswordPage extends StatelessWidget {
  const NewPasswordPage({
    super.key,
    required this.phone,
    required this.firebaseIdToken,
  });

  /// The number verified on the code page.
  final String phone;

  /// Firebase's proof of [phone], sent with the new password.
  final String firebaseIdToken;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthViewModel>(),
      child: _NewPasswordView(phone: phone, firebaseIdToken: firebaseIdToken),
    );
  }
}

class _NewPasswordView extends StatefulWidget {
  const _NewPasswordView({required this.phone, required this.firebaseIdToken});

  final String phone;
  final String firebaseIdToken;

  @override
  State<_NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<_NewPasswordView> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmation = TextEditingController();

  /// The server's field errors (`password`, `password_confirmation`), shown
  /// until the fields are edited.
  Map<String, String> _serverErrors = const {};

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    context.read<AuthViewModel>().doAction(
      ResetPasswordEvent(
        ResetPasswordRequestEntity(
          phone: widget.phone,
          firebaseIdToken: widget.firebaseIdToken,
          password: _password.text,
          passwordConfirmation: _confirmation.text,
        ),
      ),
    );
  }

  void _onError(BuildContext context, AppException exception) {
    final l10n = context.l10n;
    final fieldErrors = exception.authFieldErrors;
    if (fieldErrors.isNotEmpty) {
      setState(() => _serverErrors = fieldErrors);
      context.showSnackBar(l10n.checkHighlightedFields, isError: true);
      return;
    }

    // The server's message says what to do; the app takes the parent there.
    context.showSnackBar(exception.localizedMessage(context), isError: true);
    switch (exception) {
      // The proof of the number is too old or wrong: start again for a
      // new code.
      case ServerException(
        code: AuthErrorCodes.resetVerificationExpired ||
            AuthErrorCodes.firebaseTokenInvalid ||
            AuthErrorCodes.firebasePhoneMismatch,
      ):
        context.go(AppRoutes.forgotPassword);
      case ServerException(code: AuthErrorCodes.accountNotFound):
        context.go(AppRoutes.register);
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final password = _password.text;
    final confirmation = _confirmation.text;
    final mismatch = confirmation.isNotEmpty && confirmation != password;

    AppTextField passwordField({
      required TextEditingController controller,
      required String label,
      required String hint,
      required TextInputAction action,
      String? errorText,
    }) => AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      prefixIcon: AppIcons.lock,
      isPassword: true,
      errorText: errorText,
      textInputAction: action,
      autofillHints: const [AutofillHints.newPassword],
      // The rules follow what's typed; the server's errors go.
      onChanged: (_) => setState(() => _serverErrors = const {}),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.mahabbahRed,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RedHeader(
              horizontalPadding: 24,
              bottomPadding: 50,
              watermarkTop: 74,
              watermarkSize: const Size(250, 178),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 18.h,
                children: [
                  const AppBackButton(fallbackRoute: AppRoutes.forgotPassword),
                  RedHeaderTitle(
                    title: l10n.setNewPassword,
                    subtitle: l10n.setNewPasswordSubtitle,
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
                  child: BlocConsumer<AuthViewModel, AuthState>(
                    listenWhen: (_, state) => state.state == StateType.error,
                    listener: (context, state) =>
                        _onError(context, state.exception!),
                    builder: (context, state) {
                      if (state.data is PasswordReset) {
                        return Align(
                          alignment: Alignment.topCenter,
                          child: PasswordChangedCard(
                            title: l10n.passwordChanged,
                            message: l10n.logInWithNewPassword,
                            actionLabel: l10n.backToLogin,
                            onAction: () => context.go(AppRoutes.login),
                          ),
                        );
                      }

                      return AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 18.h,
                          children: [
                            passwordField(
                              controller: _password,
                              label: l10n.newPassword,
                              hint: l10n.enterNewPassword,
                              action: TextInputAction.next,
                              errorText: _serverErrors['password'],
                            ),
                            passwordField(
                              controller: _confirmation,
                              label: l10n.confirmNewPassword,
                              hint: l10n.typeItAgain,
                              action: TextInputAction.done,
                              errorText: mismatch
                                  ? l10n.passwordsDoNotMatch
                                  : _serverErrors['password_confirmation'],
                            ),
                            PasswordRules(
                              password: password,
                              confirmation: confirmation,
                            ),
                            AppButton(
                              label: l10n.saveNewPassword,
                              isLoading: state.state == StateType.loading,
                              onPressed:
                                  PasswordRule.allMet(password, confirmation)
                                  ? _save
                                  : null,
                            ),
                          ],
                        ),
                      );
                    },
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
