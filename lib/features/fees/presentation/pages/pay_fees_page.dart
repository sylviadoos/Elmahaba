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
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/checkout_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_installment_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/fees_error_codes.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/money_text.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/pay_online_message.dart';
import 'package:al_mahhaba_school/features/fees/presentation/statement_labels.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/pay_fees_event.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/pay_fees_state.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/pay_fees_view_model.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/pay_full_amount_section.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/pay_installments_section.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/payment_method_switch.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/statement_card.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/statement_pdf_buttons.dart';

/// Paying the statement Fees showed: the whole remaining balance, or the
/// installments the parent ticks. Pops `true` when Fees should load it
/// again.
class PayFeesPage extends StatelessWidget {
  const PayFeesPage({super.key, required this.statement});

  final FeeStatementEntity statement;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PayFeesViewModel>(),
      child: _PayFeesView(statement: statement),
    );
  }
}

class _PayFeesView extends StatefulWidget {
  const _PayFeesView({required this.statement});

  final FeeStatementEntity statement;

  @override
  State<_PayFeesView> createState() => _PayFeesViewState();
}

class _PayFeesViewState extends State<_PayFeesView> {
  bool _inFull = true;

  /// The installments ticked (their `payKey`s).
  Set<String> _picked = {};

  void _payOnline(List<FeeInstallmentEntity> installments) {
    context.read<PayFeesViewModel>().doAction(
      PayOnlineEvent(
        // The `studentId` Fees loaded it with.
        childId: widget.statement.student.id,
        payKeys: [for (final installment in installments) installment.payKey],
      ),
    );
  }

  /// Pays on Skoolex Pay's page. Paid or not, Fees then loads the
  /// statement again: the installments may be paid or on their way.
  Future<void> _openCheckout(CheckoutEntity checkout) async {
    await context.push(AppRoutes.feesCheckout, extra: checkout);
    if (mounted) context.pop(true);
  }

  void _onError(AppException exception) {
    context.showSnackBar(exception.payOnlineMessage(context), isError: true);
    if (exception is UnauthorizedException) {
      context.logOut();
    } else if (exception case ServerException(
      code: FeesErrorCodes.payOnlineNothingDue ||
          FeesErrorCodes.payOnlineDisabled,
    )) {
      // What Fees showed is out of date: back to it, loaded again.
      context.pop(true);
    }
  }

  /// In the app's language when the school has it.
  String _studentName(BuildContext context) {
    final student = widget.statement.student;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final preferred = isArabic ? student.nameAr : student.nameEn;
    return preferred.isNotEmpty ? preferred : student.name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final statement = widget.statement;
    final remaining = statement.remainingBalance;
    // In full: every installment that can be paid.
    final toPay = [
      for (final installment in statement.installments)
        if (installment.canPay &&
            (_inFull || _picked.contains(installment.payKey)))
          installment,
    ];
    final amountNow = toPay.fold(0.0, (sum, i) => sum + (i.amount ?? 0));
    // Its statement only once the earlier installments are ticked too: no
    // statement for a second installment while the first is unpaid.
    final keysToPay = {for (final installment in toPay) installment.payKey};
    final outOfOrder = [
      for (final installment in toPay)
        if (!installment.isInOrderWith(keysToPay)) installment,
    ];
    final inOrder = outOfOrder.isEmpty;
    // Why, in the school's own words — the same sentences its website
    // shows, each naming the fee whose earlier installments come first.
    // One line per reason; the app's own when the school sends none.
    final lockedReasons = {
      for (final installment in outOfOrder)
        if (installment.lockedReason.isNotEmpty) installment.lockedReason,
    };
    final name = _studentName(context);

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
              child: Row(
                spacing: 10.w,
                children: [
                  const AppBackButton(fallbackRoute: AppRoutes.fees),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.payFees,
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 24.sp,
                            height: 28 / 24,
                            letterSpacing: 0,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          name,
                          textDirection: name.textDirection,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 13.sp,
                            color: AppColors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  6.h,
                  20.w,
                  math.max(40.h, MediaQuery.paddingOf(context).bottom + 16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 18.h,
                  children: [
                    StatementCard(
                      icon: AppIcons.navFees,
                      title: StatementLabels.choosePaymentMethod,
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 14.h,
                          children: [
                            PaymentMethodSwitch(
                              labels: [
                                l10n.payFullAmount,
                                l10n.payInInstallments,
                              ],
                              selected: _inFull ? 0 : 1,
                              onSelected: (index) =>
                                  setState(() => _inFull = index == 0),
                            ),
                            if (_inFull)
                              PayFullAmountSection(
                                total: statement.totalAmount,
                                paid: statement.paidAmount,
                                remaining: remaining,
                              )
                            else
                              PayInstallmentsSection(
                                statement: statement,
                                picked: _picked,
                                payable: amountNow,
                                onTogglePicked: (id) => setState(
                                  () => _picked = _picked.contains(id)
                                      ? ({..._picked}..remove(id))
                                      : {..._picked, id},
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10.h,
                      children: [
                        BlocConsumer<PayFeesViewModel, PayFeesState>(
                          listener: (context, state) {
                            if (state.data case final checkout?) {
                              _openCheckout(checkout);
                            }
                            if (state.exception case final exception?) {
                              _onError(exception);
                            }
                          },
                          builder: (context, state) => AppButton(
                            label: amountNow > 0
                                ? l10n.payOnlineAmount(context.egp(amountNow))
                                : l10n.payOnline,
                            icon: AppSvgIcon(AppIcons.navFees, size: 20.r),
                            isLoading: state.state == StateType.loading,
                            onPressed:
                                toPay.isNotEmpty && statement.payOnlineEnabled
                                ? () => _payOnline(toPay)
                                : null,
                          ),
                        ),
                        Text(
                          l10n.paymentBySkoolex,
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.mahabbahRed,
                          ),
                        ),
                        StatementPdfButtons(
                          statement: statement,
                          // In full: every fee; else what's ticked.
                          installments: _inFull ? null : toPay,
                          enabled: inOrder,
                        ),
                        if (!inOrder)
                          for (final reason
                              in lockedReasons.isEmpty
                                  ? [l10n.tickEarlierInstallmentsFirst]
                                  : lockedReasons)
                            Text(
                              reason,
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 12.sp,
                                color: AppColors.slate,
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
