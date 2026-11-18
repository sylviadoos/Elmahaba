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
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/scrollable_fill.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/verification_message.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_state.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:al_mahhaba_school/core/widgets/red_header_title.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/otp_code_input.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/prompt_link.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/resend_countdown.dart';

/// Enter the 6-digit SMS code, with a resend countdown. The code is sent
/// when the page opens; once it checks out, the account is created and the
/// parent goes to Log in.
class OtpPage extends StatelessWidget {
  const OtpPage({super.key, required this.request, required this.phoneMasked});

  /// What the parent filled in on Register.
  final RegisterRequestEntity request;

  /// e.g. "0120****154".
  final String phoneMasked;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthViewModel>()..doAction(SendOtpEvent(request)),
      child: _OtpView(request: request, phoneMasked: phoneMasked),
    );
  }
}

class _OtpView extends StatefulWidget {
  const _OtpView({required this.request, required this.phoneMasked});

  final RegisterRequestEntity request;
  final String phoneMasked;

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  static const int _codeLength = 6;

  /// 5 minutes: as long as the code lasts.
  static const int _resendSeconds = 300;

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

  /// The page's own 5 minutes, or the sender's [wait] when longer (the
  /// school gives one).
  void _startCountdown([Duration? wait]) {
    _timer?.cancel();
    _secondsLeft = math.max(wait?.inSeconds ?? 0, _resendSeconds);
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
    context.read<AuthViewModel>().doAction(SendOtpEvent(widget.request));
  }

  void _verify() {
    _sendingCode = false;
    FocusScope.of(context).unfocus();
    context.read<AuthViewModel>().doAction(
      VerifyOtpEvent(widget.request, _codeController.text),
    );
  }

  void _changeNumber() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.register);

  /// A fresh Log in, even when the one the parent started is under
  /// Register (see the route).
  void _toLogin() => context.go(AppRoutes.login, extra: widget.request.phone);

  void _onState(BuildContext context, AuthState state) {
    if (state.data case OtpSent(:final resendAfter)) {
      // The countdown runs from when the code really left.
      setState(() => _startCountdown(resendAfter));
      return;
    }
    if (state.data is Registered) {
      context.showSnackBar(context.l10n.accountCreated);
      _toLogin();
      return;
    }

    final exception = state.exception;
    if (exception == null) return;
    if (_sendingCode) _stopCountdown();
    context.showSnackBar(exception.verificationMessage(context), isError: true);
    if (exception case ServerException(
      code: AuthErrorCodes.alreadyRegistered,
    )) {
      _toLogin();
    }
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
                  const AppBackButton(fallbackRoute: AppRoutes.register),
                  RedHeaderTitle(
                    title: l10n.verifyYourNumber,
                    subtitle: l10n.otpSentTo,
                    subtitleBold: widget.phoneMasked,
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
