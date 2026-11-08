import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';

/// A child's page with no child to show: [loading] while the children
/// load, their error with "Try again", or "No children yet" with
/// "Add a child".
class NoChildrenState extends StatelessWidget {
  const NoChildrenState({
    super.key,
    required this.children,
    required this.loading,
  });

  /// The children, from the shared `ChildrenViewModel`.
  final BaseState<List<ChildEntity>> children;
  final Widget loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return switch (children.state) {
      StateType.success => StateMessage(
        icon: AppIcons.user,
        title: l10n.noChildrenYet,
        action: AppButton(
          label: l10n.addAChild,
          expand: false,
          onPressed: () => context.push(AppRoutes.addChildren),
        ),
      ),
      StateType.error => StateMessage(
        icon: AppIcons.user,
        title: children.exception!.localizedMessage(context),
        action: AppButton(
          label: l10n.tryAgain,
          expand: false,
          onPressed: () => context.read<ChildrenViewModel>().doAction(
            const LoadChildrenEvent(),
          ),
        ),
      ),
      _ => loading,
    };
  }
}
