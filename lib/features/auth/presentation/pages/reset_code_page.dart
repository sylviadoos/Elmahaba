import 'dart:async';
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
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/red_header_title.dart';
import 'package:al_mahhaba_school/core/widgets/scrollable_fill.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/verification_message.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_state.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/otp_code_input.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/prompt_link.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/resend_countdown.dart';

/// Forgot password, step 2: the 6-digit SMS code sent to [phone] when the
/// page opens, with a resend countdown. Once Firebase checks it, the new
/// password comes next.
class ResetCodePage extends StatelessWidget {
  const ResetCodePage({super.key, required this.phone});

  /// As typed on Forgot password, e.g. "01012345678".
  final String phone;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AuthViewModel>()..doAction(SendResetCodeEvent(phone)),
      child: _ResetCodeView(phone: phone),
    );
  }
}

class _ResetCodeView extends StatefulWidget {
  const _ResetCodeView({required this.phone});

  final String phone;

  @override
  State<_ResetCodeView> createState() => _ResetCodeViewState();
}

class _ResetCodeViewState extends State<_ResetCodeView> {
  static const int _codeLength = 6;
  static const int _resendSeconds = 45;

  final TextEditingController _codeController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = _resendSeconds;

  /// Whether the running action is sending the code (not checking it).
  bool _sendingCode = true;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _secondsLeft = _resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  /// Lets the parent ask for a new code right away.
  void _stopCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 0);
  }

  void _resend() {
    _sendingCode = true;
    _codeController.clear();
    setState(_startCountdown);
    context.read<AuthViewModel>().doAction(SendResetCodeEvent(widget.phone));
  }

  void _verify() {
    _sendingCode = false;
    FocusScope.of(context).unfocus();
    context.read<AuthViewModel>().doAction(
      VerifyResetCodeEvent(_codeController.text),
    );
  }

  void _changeNumber() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.forgotPassword);

  void _onState(BuildContext context, AuthState state) {
    switch (state.data) {
      case OtpSent():
        // The countdown runs from when the code really left.
        setState(_startCountdown);
        return;
      case PhoneVerified(:final firebaseIdToken):
        context.push(
          AppRoutes.newPassword,
          extra: (widget.phone, firebaseIdToken),
        );
        return;
      default:
    }

    final exception = state.exception;
    if (exception == null) return;
    if (_sendingCode) _stopCountdown();
    context.showSnackBar(exception.verificationMessage(context), isError: true);
  }

  /// "01012345678" → "+20 10 •••• 5678", kept on one line and left to
  /// right in Arabic.
  static String _masked(String phone) {
    if (phone.length < 7) return phone;
    final national = phone.startsWith('0') ? phone.substring(1) : phone;
    return '+20 ${national.substring(0, 2)} •••• '
            '${national.substring(national.length - 4)}'
        .ltrIsolated;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isComplete = _codeController.text.length == _codeLength;

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
                    title: l10n.enterTheCode,
                    subtitle: l10n.resetCodeSentTo,
                    subtitleBold: _masked(widget.phone),
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
                    26.h,
                    24.w,
                    math.max(36.h, bottomInset + 16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 22.h,
                    children: [
                      Center(
                        child: IconBox(
                          AppIcons.smartphoneOtp,
                          size: 72.r,
                          iconSize: 32.r,
                          radius: 24.r,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 10.h,
                        children: [
                          Text(
                            l10n.enterVerificationCode,
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          OtpCodeInput(
                            controller: _codeController,
                            length: _codeLength,
                            // Enables Verify once all digits are in.
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                      Center(
                        child: _secondsLeft > 0
                            ? ResendCountdown(seconds: _secondsLeft)
                            : PromptLink(
                                prompt: l10n.didntGetIt,
                                action: l10n.resendCode,
                                onTap: _resend,
                                fontSize: 14,
                              ),
                      ),
                      BlocConsumer<AuthViewModel, AuthState>(
                        listenWhen: (_, state) =>
                            state.state == StateType.success ||
                            state.state == StateType.error,
                        listener: _onState,
                        builder: (context, state) => AppButton(
                          label: l10n.verify,
                          isLoading: state.state == StateType.loading,
                          onPressed: isComplete ? _verify : null,
                        ),
                      ),
                      const Spacer(),
                      PromptLink(
                        prompt: l10n.wrongNumber,
                        action: l10n.changeIt,
                        onTap: _changeNumber,
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
