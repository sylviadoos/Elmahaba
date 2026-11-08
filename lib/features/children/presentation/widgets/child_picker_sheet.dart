import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/child_display.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/all_children_avatar.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_avatar.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_picker_row.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/add_child_button.dart';

/// "Choose a child": "All children" first ([withAll]), the parent's
/// children, the one shown ticked, then "Link another child". Pops the
/// index of the one picked, or [all].
class ChildPickerSheet extends StatelessWidget {
  const ChildPickerSheet({
    super.key,
    required this.children,
    required this.selected,
    this.withAll = false,
  });

  final List<ChildEntity> children;

  /// An index in [children], or [all].
  final int selected;
  final bool withAll;

  /// "All children" picked.
  static const int all = -1;

  /// Over the nav bar too; null when it's closed without picking.
  static Future<int?> show(
    BuildContext context, {
    required List<ChildEntity> children,
    required int selected,
    bool withAll = false,
  }) => showModalBottomSheet<int>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    barrierColor: AppColors.scrim,
    constraints: BoxConstraints(maxHeight: 560.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
    builder: (_) => ChildPickerSheet(
      children: children,
      selected: selected,
      withAll: withAll,
    ),
  );

  void _linkAnother(BuildContext context) {
    final router = GoRouter.of(context);
    Navigator.pop(context);
    router.push(AppRoutes.addChildren);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        math.max(30.h, MediaQuery.paddingOf(context).bottom + 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6.h,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.handle,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 10.h, 4.w, 6.h),
            child: Row(
              spacing: 8.w,
              children: [
                Expanded(
                  child: Text(
                    l10n.chooseChild,
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 18.sp,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Text(
                  l10n.childrenLinked(children.length),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 13.sp,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: children.length + (withAll ? 1 : 0),
              separatorBuilder: (_, _) => SizedBox(height: 6.h),
              itemBuilder: (context, row) {
                final index = withAll ? row - 1 : row;
                if (index < 0) {
                  return ChildPickerRow(
                    avatar: AllChildrenAvatar(children: children, size: 44.r),
                    title: l10n.allChildren,
                    subtitle: children.firstNames(context),
                    isSelected: selected == all,
                    onTap: () => Navigator.pop(context, all),
                  );
                }
                final child = children[index];
                final name = child.displayName(context);
                return ChildPickerRow(
                  avatar: ChildAvatar(name: name, index: index, size: 44.r),
                  title: name,
                  subtitle: child.gradeAndClass,
                  isSelected: index == selected,
                  onTap: () => Navigator.pop(context, index),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: AddChildButton(
              label: l10n.linkAnotherChild,
              onPressed: () => _linkAnother(context),
            ),
          ),
        ],
      ),
    );
  }
}
