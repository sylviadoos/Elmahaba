import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/confirm_dialog.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/no_children_state.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/money_text.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/fees_event.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/fees_state.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/fees_view_model.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/fee_statement_card.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/fees_skeleton.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/student_summary_card.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/parent_tab_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';

/// The selected child's fee statement: who it's for, the fees, the totals,
/// and paying them.
class FeesPage extends StatelessWidget {
  const FeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FeesViewModel>(),
      child: const _FeesView(),
    );
  }
}

class _FeesView extends StatefulWidget {
  const _FeesView();

  @override
  State<_FeesView> createState() => _FeesViewState();
}

class _FeesViewState extends State<_FeesView> {
  @override
  void initState() {
    super.initState();
    _loadStatement();
  }

  /// The selected child's statement; nothing to load without children.
  void _loadStatement({bool refresh = false}) {
    final child = context.read<ChildrenViewModel>().state.selectedChild;
    if (child == null) return;
    context.read<FeesViewModel>().doAction(
      LoadFeesEvent(child.studentId, refresh: refresh),
    );
  }

  /// Pay fees returns `true` once the statement changed (a payment
  /// started) or turned out stale.
  Future<void> _pay(FeeStatementEntity statement) async {
    final changed = await context.push<bool>(
      AppRoutes.feesPay,
      extra: statement,
    );
    if (changed == true && mounted) _loadStatement(refresh: true);
  }

  /// Adds an optional fee to the statement or drops it, once the parent
  /// says yes. The school changes it at once, so it's worth asking.
  Future<void> _changeOptional(FeeEntity fee, bool add) async {
    final l10n = context.l10n;
    final child = context.read<ChildrenViewModel>().state.selectedChild;
    if (child == null) return;
    final confirmed = await ConfirmDialog.show(
      context,
      title: add ? l10n.confirmOptionalFee : l10n.dropOptionalFee,
      message: add
          ? l10n.confirmOptionalFeeMessage(fee.name, context.egp(fee.amount))
          : l10n.dropOptionalFeeMessage(fee.name),
      confirmLabel: add ? l10n.yesPay : l10n.yesDrop,
    );
    if (!confirmed || !mounted) return;
    context.read<FeesViewModel>().doAction(
      ChangeOptionalFeeEvent(
        childId: child.studentId,
        feeId: fee.id!,
        add: add,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childrenState = context.select(
      (ChildrenViewModel viewModel) => viewModel.state.children,
    );
    final children = childrenState.data ?? const <ChildEntity>[];

    return BlocListener<ChildrenViewModel, ChildrenState>(
      // The children arrived or changed (a child linked, the list
      // refreshed), or another one was picked, here or on another page.
      listenWhen: (previous, current) =>
          previous.children.data != current.children.data ||
          current.showsOtherChildThan(previous),
      listener: (context, state) => _loadStatement(),
      child: ParentTabPage(
        title: context.l10n.fees,
        selectedChild: context.watchSelectedChildIndex(),
        onChildSelected: (index) =>
            context.selectChild(children[index].studentId),
        children: [
          if (children.isEmpty)
            NoChildrenState(
              children: childrenState,
              loading: const FeesSkeleton(),
            )
          else
            BlocConsumer<FeesViewModel, FeesState>(
              // The school turned a change down — the fee is on the
              // statement already, or a payment keeps it there.
              listenWhen: (previous, current) =>
                  previous.changeFailed != current.changeFailed &&
                  current.changeFailed != null,
              listener: (context, state) => context.showSnackBar(
                state.changeFailed!.localizedMessage(context),
                isError: true,
              ),
              builder: (context, state) => state.statement.when(
                initial: () => const FeesSkeleton(),
                loading: () => const FeesSkeleton(),
                error: (exception) => StateMessage(
                  icon: AppIcons.navFees,
                  title: exception.localizedMessage(context),
                  action: RetryOrLogInButton(
                    exception: exception,
                    onRetry: _loadStatement,
                  ),
                ),
                success: (statement) =>
                    _statement(context, statement, state.changingFeeId),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statement(
    BuildContext context,
    FeeStatementEntity statement,
    int? changingFeeId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 18.h,
      children: [
        StudentSummaryCard(student: statement.student),
        FeeStatementCard(
          statement: statement,
          onChangeOptional: _changeOptional,
          changingFeeId: changingFeeId,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.h,
          children: [
            AppButton(
              label: context.l10n.payFeesAmount(
                context.egp(statement.remainingBalance),
              ),
              icon: AppSvgIcon(AppIcons.navFees, size: 20.r),
              onPressed: () => _pay(statement),
            ),
            // StatementPdfButtons(statement: statement),
          ],
        ),
      ],
    );
  }
}
