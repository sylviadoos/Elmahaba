import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/children_count_badge.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/linked_children_list.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/linked_children_skeleton.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/no_children_card.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';

/// "Your children" with their count, then the list: a skeleton while it
/// loads, an error with [onRetry], or a placeholder when there are none.
class YourChildrenSection extends StatelessWidget {
  const YourChildrenSection({
    super.key,
    required this.children,
    required this.onRetry,
  });

  final BaseState<List<ChildEntity>> children;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loaded = children.data;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16.h,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.yourChildren,
              style: context.textTheme.titleLarge?.copyWith(
                fontSize: 16.sp,
                height: 1.3,
              ),
            ),
            if (loaded != null) ChildrenCountBadge(count: loaded.length),
          ],
        ),
        children.when(
          initial: () => const LinkedChildrenSkeleton(),
          loading: () => const LinkedChildrenSkeleton(),
          error: (exception) => StateMessage(
            icon: AppIcons.user,
            title: exception.localizedMessage(context),
            action: RetryOrLogInButton(exception: exception, onRetry: onRetry),
          ),
          success: (list) => list.isEmpty
              ? const NoChildrenCard()
              : LinkedChildrenList(children: list),
        ),
      ],
    );
  }
}
