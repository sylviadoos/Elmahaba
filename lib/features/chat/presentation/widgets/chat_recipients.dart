import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/child_display.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_avatar.dart';

/// Above the message box while every child's chat is shown: "About",
/// "General" (picked at first: about none of them) and a chip per child;
/// the message is about the one picked.
class ChatRecipients extends StatelessWidget {
  const ChatRecipients({
    super.key,
    required this.children,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final List<ChildEntity> children;

  /// The student ID of the child picked; null for "General".
  final int? selected;

  /// Gets the student ID, or null for "General".
  final ValueChanged<int?> onSelected;

  /// False while sending.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Row(
      spacing: 8.w,
      children: [
        Text(
          context.l10n.messageAbout,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.slate,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 6.w,
              children: [
                _chip(
                  context,
                  label: context.l10n.chatGeneral,
                  avatar: Container(
                    width: 24.r,
                    height: 24.r,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.blush,
                      shape: BoxShape.circle,
                    ),
                    child: AppSvgIcon(
                      AppIcons.megaphoneGeneral,
                      size: 13.r,
                      color: AppColors.mahabbahRed,
                    ),
                  ),
                  isSelected: selected == null,
                  onTap: () => onSelected(null),
                ),
                for (final (index, child) in children.indexed)
                  _childChip(context, index, child),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _childChip(BuildContext context, int index, ChildEntity child) {
    final name = child.firstName(context);
    return _chip(
      context,
      label: name,
      // Each child's colors, as in the picker.
      avatar: ChildAvatar(
        name: name,
        index: index,
        size: 24.r,
        fontSize: 11.sp,
      ),
      isSelected: child.studentId == selected,
      onTap: () => onSelected(child.studentId),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required Widget avatar,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? AppColors.blushPale : AppColors.white,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? AppColors.mahabbahRed : AppColors.line,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(4.w, 4.h, 12.w, 4.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6.w,
              children: [
                avatar,
                Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.mahabbahRed : AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
