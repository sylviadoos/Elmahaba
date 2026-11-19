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
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/red_header_title.dart';
import 'package:al_mahhaba_school/core/widgets/scrollable_fill.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/verification_message.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/otp_code_input.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/prompt_link.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/resend_countdown.dart';
import 'package:al_mahhaba_school/features/children/domain/children_error_codes.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_view_model.dart';

/// Adding a child, step 2 when the school has another phone for them: the
/// 6-digit code sent there, with a 5-minute resend countdown. When the
/// school gave the number, it's sent as the page opens — by the school
/// first or Firebase first (`AppConfig.smsMisrFirst`); otherwise the school
/// texted it already. "Didn't get it" takes turns between the two (see
/// `LinkChildCodeViewModel`). Once it's right the child is linked, and Add
/// children shows it.
class LinkChildCodePage extends StatelessWidget {
  const LinkChildCodePage({super.key, required this.verification});

  /// As linking answered (`otp_required`).
  final LinkVerificationEntity verification;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final viewModel = getIt<LinkChildCodeViewModel>();
        // No number: the school texted the code already.
        if (verification.phone != null) {
          viewModel.doAction(SendLinkCodeEvent(verification));
        }
        return viewModel;
      },
      child: _LinkChildCodeView(verification: verification),
    );
  }
}

class _LinkChildCodeView extends StatefulWidget {
  const _LinkChildCodeView({required this.verification});

  final LinkVerificationEntity verification;

  @override
  State<_LinkChildCodeView> createState() => _LinkChildCodeViewState();
}

class _LinkChildCodeViewState extends State<_LinkChildCodeView> {
  static const int _codeLength = 6;

  /// 5 minutes: as long as the code lasts.
  static const int _resendSeconds = 300;

  final TextEditingController _codeController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 0;

  /// As the school last sent it: a new code brings a new count of resends.
  late LinkVerificationEntity _verification = widget.verification;

  /// Why the last code didn't work, under the boxes, with the tries left.
  String? _codeError;

  /// No more codes can be asked for.
  bool _noResends = false;

  @override
  void initState() {
    super.initState();
    _countFrom(_verification);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  /// A code sent: 5 minutes, or the school's wait when longer.
  void _countFrom(LinkVerificationEntity verification) => _startCountdown(
    math.max(verification.resendAfter.inSeconds, _resendSeconds),
  );

  void _startCountdown(int seconds) {
    _timer?.cancel();
    setState(() => _secondsLeft = math.max(seconds, 0));
    if (_secondsLeft == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  void _check() {
    FocusScope.of(context).unfocus();
    context.read<LinkChildCodeViewModel>().doAction(
      CheckLinkCodeEvent(
        token: _verification.token,
        code: _codeController.text,
      ),
    );
  }

  void _resend() => context.read<LinkChildCodeViewModel>().doAction(
    SendLinkCodeEvent(_verification),
  );

  /// Back to Add children: to start again, or done.
  void _close() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.addChildren);

  void _onChecked(BuildContext context, LinkChildCodeState state) {
    final checking = state.checking;
    if (checking.data case final child?) {
      // Add children, underneath, says so and lists the child.
      context.read<ChildrenViewModel>().doAction(ChildLinkVerifiedEvent(child));
      _close();
      return;
    }
    final exception = checking.exception;
    if (exception == null) return;
    final message = exception.localizedMessage(context);
    if (exception is UnauthorizedException) {
      context.showSnackBar(message, isError: true);
      context.logOut();
      return;
    }
    switch (exception) {
      // Firebase's code: wrong, or too old. Its own message is technical
      // English, so the app's is shown.
      case PhoneVerificationException():
        _codeController.clear();
        setState(() => _codeError = exception.verificationMessage(context));
      case ServerException(code: ChildrenErrorCodes.codeIncorrect, :final body):
        final attemptsLeft = _bodyInt(body, 'attempts_left');
        _codeController.clear();
        setState(
          () => _codeError = attemptsLeft == null
              ? message
              : '$message ${context.l10n.codeAttemptsLeft(attemptsLeft)}',
        );
      case ServerException(code: ChildrenErrorCodes.codeExpired):
        // A new one can be asked for at once.
        _codeController.clear();
        _timer?.cancel();
        setState(() {
          _secondsLeft = 0;
          _codeError = message;
        });
      // Start again from the national ID, or no more tries for now, or
      // linked meanwhile: back to Add children, saying why.
      case ServerException(
        code: ChildrenErrorCodes.verificationInvalid ||
            ChildrenErrorCodes.attemptsExceeded ||
            ChildrenErrorCodes.alreadyLinked,
      ):
        context.showSnackBar(message, isError: true);
        _close();
      default:
        context.showSnackBar(message, isError: true);
    }
  }

  void _onResent(BuildContext context, LinkChildCodeState state) {
    final resending = state.resending;
    if (resending.data case final verification?) {
      _verification = verification;
      _codeController.clear();
      setState(() => _codeError = null);
      _countFrom(verification);
      return;
    }
    final exception = resending.exception;
    if (exception == null) return;
    final message = exception.localizedMessage(context);
    if (exception is UnauthorizedException) {
      context.showSnackBar(message, isError: true);
      context.logOut();
      return;
    }
    switch (exception) {
      case ServerException(code: ChildrenErrorCodes.resendTooSoon, :final body):
        context.showSnackBar(message, isError: true);
        _startCountdown(_bodyInt(body, 'retry_after') ?? 0);
      case ServerException(code: ChildrenErrorCodes.resendLimit):
        context.showSnackBar(message, isError: true);
        setState(() => _noResends = true);
      case ServerException(code: ChildrenErrorCodes.verificationInvalid):
        context.showSnackBar(message, isError: true);
        _close();
      default:
        context.showSnackBar(message, isError: true);
    }
  }

  /// Answered: a result or an error.
  static bool _isDone(BaseState<Object?> state) =>
      state.state == StateType.success || state.state == StateType.error;

  /// [key] of an error answer: at its top, or under `data`.
  static int? _bodyInt(Map<String, dynamic> body, String key) {
    final data = body['data'];
    final value = body[key] ?? (data is Map ? data[key] : null);
    return jsonDouble(value)?.toInt();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isComplete = _codeController.text.length == _codeLength;
    // The school's resends are counted; Firebase's aren't — after the
    // school's code, Firebase sends the next even with none left.
    final schoolCanResend = !_noResends && _verification.resendsLeft > 0;

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
                  const AppBackButton(fallbackRoute: AppRoutes.addChildren),
                  RedHeaderTitle(
                    title: l10n.enterTheCode,
                    subtitle: l10n.linkCodeSentTo,
                    // As the school sent it, left to right in Arabic.
                    subtitleBold: _verification.maskedPhone.ltrIsolated,
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
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<LinkChildCodeViewModel, LinkChildCodeState>(
                        listenWhen: (previous, current) =>
                            previous.checking != current.checking &&
                            _isDone(current.checking),
                        listener: _onChecked,
                      ),
                      BlocListener<LinkChildCodeViewModel, LinkChildCodeState>(
                        listenWhen: (previous, current) =>
                            previous.resending != current.resending &&
                            _isDone(current.resending),
                        listener: _onResent,
                      ),
                    ],
                    child:
                        BlocBuilder<LinkChildCodeViewModel, LinkChildCodeState>(
                          builder: (context, state) => Column(
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
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  OtpCodeInput(
                                    controller: _codeController,
                                    length: _codeLength,
                                    // Enables Verify once all digits are in; the
                                    // error goes as a new code is typed.
                                    onChanged: (_) =>
                                        setState(() => _codeError = null),
                                  ),
                                  if (_codeError case final error?)
                                    Text(
                                      error,
                                      textAlign: TextAlign.center,
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            fontSize: 13.sp,
                                            color: AppColors.error,
                                          ),
                                    ),
                                ],
                              ),
                              if (state.nextByFirebase || schoolCanResend)
                                Center(
                                  child: _secondsLeft > 0
                                      ? ResendCountdown(seconds: _secondsLeft)
                                      : PromptLink(
                                          prompt: l10n.didntGetIt,
                                          action: l10n.resendCode,
                                          onTap: state.isBusy ? () {} : _resend,
                                          fontSize: 14,
                                        ),
                                ),
                              AppButton(
                                label: l10n.verify,
                                isLoading:
                                    state.checking.state == StateType.loading,
                                onPressed: isComplete && !state.isBusy
                                    ? _check
                                    : null,
                              ),
                            ],
                          ),
                        ),
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
