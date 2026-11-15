import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/child_display.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/all_children_avatar.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_avatar.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_picker_sheet.dart';

/// The child shown, for the red headers: their initial, name and grade, and
/// how many children there are. Tapping it opens [ChildPickerSheet] to pick
/// another, or all of them ([withAll]).
class ChildPicker extends StatelessWidget {
  const ChildPicker({
    super.key,
    required this.children,
    required this.selected,
    required this.onSelected,
    this.withAll = false,
    this.compact = false,
    this.hasNews = false,
  });

  /// The parent's children; [selected] is one of them, or [all].
  final List<ChildEntity> children;
  final int selected;
  final ValueChanged<int> onSelected;

  /// "All children" can be picked.
  final bool withAll;

  /// Smaller, with the first name and without the count, for a header
  /// with buttons beside it.
  final bool compact;

  /// A gold dot on its corner: news about the children not shown.
  final bool hasNews;

  /// "All children" shown.
  static const int all = ChildPickerSheet.all;

  /// For headers that make room for it.
  static double get height => 60.h;
  static double get compactHeight => 44.h;

  Future<void> _pick(BuildContext context) async {
    final picked = await ChildPickerSheet.show(
      context,
      children: children,
      selected: selected,
      withAll: withAll,
    );
    if (picked != null && picked != selected) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final child = selected == all ? null : children[selected];
    final name = child == null
        ? context.l10n.allChildren
        : compact
        ? child.firstName(context)
        : child.displayName(context);
    final avatarSize = compact ? 34.r : 42.r;
    final down = RotatedBox(
      quarterTurns: 1,
      child: AppSvgIcon(
        AppIcons.chevronRight,
        size: compact ? 16.r : 14.r,
        color: AppColors.mahabbahRed,
      ),
    );

    final picker = Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(compact ? 14.r : 16.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _pick(context),
        child: Container(
          height: compact ? compactHeight : height,
          padding: EdgeInsetsDirectional.only(
            start: compact ? 5.w : 8.w,
            end: compact ? 10.w : 12.w,
          ),
          child: Row(
            spacing: compact ? 8.w : 10.w,
            children: [
              if (child == null)
                AllChildrenAvatar(children: children, size: avatarSize)
              else
                ChildAvatar(
                  name: name,
                  index: selected,
                  size: avatarSize,
                  fontSize: compact ? 14.sp : null,
                ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: compact ? 14.sp : 15.sp,
                        height: compact ? 17 / 14 : 19 / 15,
                        fontWeight: compact ? FontWeight.w700 : FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      child?.gradeAndClass ?? children.firstNames(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: compact ? 11.sp : 12.sp,
                        height: compact ? 14 / 11 : null,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
              if (compact)
                down
              else
                Container(
                  height: 32.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: const ShapeDecoration(
                    color: AppColors.blush,
                    shape: StadiumBorder(),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4.w,
                    children: [
                      Text(
                        context.l10n.childrenCount(children.length),
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mahabbahRed,
                        ),
                      ),
                      down,
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (!hasNews) return picker;
    final dot = 12.r;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        picker,
        // A 2 px ring of the header's red around it.
        PositionedDirectional(
          top: -3.r - 2,
          end: -3.r - 2,
          child: IgnorePointer(
            child: Container(
              width: dot + 4,
              height: dot + 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold,
                border: Border.all(color: AppColors.mahabbahRed, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
