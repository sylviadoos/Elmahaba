import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/scrollable_fill.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/auth_header_title.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/otp_code_input.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/prompt_link.dart';
import 'package:al_mahhaba_school/features/children/data/mock_children.dart';

/// Enter the 6-digit SMS code, with a resend countdown.
class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const int _codeLength = 6;
  static const int _resendSeconds = 45;

  final TextEditingController _codeController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = _resendSeconds;

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

  void _resend() {
    // TODO: ask the API to send a new code.
    _codeController.clear();
    setState(_startCountdown);
  }

  void _changeNumber() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.register);

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
                  AuthHeaderTitle(
                    title: l10n.verifyYourNumber,
                    subtitle: l10n.otpSentTo,
                    subtitleBold: mockParentPhone,
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
                            ? _Countdown(seconds: _secondsLeft)
                            : PromptLink(
                                prompt: l10n.didntGetIt,
                                action: l10n.resendCode,
                                onTap: _resend,
                                fontSize: 14,
                              ),
                      ),
                      AppButton(
                        label: l10n.verify,
                        // TODO: verify the code (Cubit) before continuing.
                        onPressed: isComplete
                            ? () => context.push(AppRoutes.addChildren)
                            : null,
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

/// "Resend code in 0:45", with the time in bold.
class _Countdown extends StatelessWidget {
  const _Countdown({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final time = '0:${seconds.toString().padLeft(2, '0')}';
    final text = context.l10n.resendCodeIn(time);
    final timeAt = text.indexOf(time);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, timeAt)),
          TextSpan(
            text: time,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          TextSpan(text: text.substring(timeAt + time.length)),
        ],
      ),
      style: context.textTheme.bodyMedium?.copyWith(
        height: 44 / 14,
        color: AppColors.slate,
      ),
    );
  }
}
