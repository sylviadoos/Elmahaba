import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/chat/data/mock_chat.dart';

/// A school message: who it's for, title, text, then a link button or
/// quick-reply options. Once answered, the options are replaced by
/// "You replied" and the reply bubble.
class ChatMessageCard extends StatelessWidget {
  const ChatMessageCard({
    super.key,
    required this.message,
    required this.answer,
    required this.onAnswer,
  });

  final ChatMessage message;

  /// Label of the option picked, if any.
  final String? answer;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final picked = message.options.where((o) => o.label == answer).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8.h,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: MessageKindChip(
            isGeneral: message.isGeneral,
            label: [
              message.isGeneral ? l10n.chatGeneral : l10n.chatPrivate,
              message.audience,
              message.time,
            ].join(' · '),
            bold: true,
          ),
        ),
        _AccentCard(
          isGeneral: message.isGeneral,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10.h,
            children: [
              Row(
                spacing: 10.w,
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.blush,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: SvgPicture.asset(
                      AppImages.logoMarkRed,
                      width: 24.r,
                      height: 17.r,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      message.title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 15.sp,
                        height: 20 / 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                message.body,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
              ),
              if (message.action != null)
                _OutlineAction(
                  label: message.action!,
                  onTap: () => context.go(switch (message.actionLink) {
                    ChatLink.fees => AppRoutes.fees,
                    ChatLink.results || null => AppRoutes.results,
                  }),
                ),
              if (picked == null)
                for (final option in message.options)
                  _OutlineAction(
                    label: option.label,
                    onTap: () => onAnswer(option.label),
                  )
              else
                Row(
                  spacing: 6.w,
                  children: [
                    AppSvgIcon(
                      AppIcons.check,
                      size: 14.r,
                      color: AppColors.mahabbahRed,
                    ),
                    Text(
                      l10n.youReplied,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.mahabbahRed,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (picked != null)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Container(
              constraints: BoxConstraints(maxWidth: 270.w),
              margin: EdgeInsets.only(top: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.actionRed,
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(16.r),
                  topEnd: Radius.circular(4.r),
                  bottomStart: Radius.circular(16.r),
                  bottomEnd: Radius.circular(16.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4.h,
                children: [
                  Text(
                    picked.reply,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    l10n.you,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// "General" (red) or "Private" (blush) pill with its icon.
class MessageKindChip extends StatelessWidget {
  const MessageKindChip({
    super.key,
    required this.isGeneral,
    required this.label,
    this.bold = false,
  });

  final bool isGeneral;
  final String label;

  /// Message chips are bolder and wider than the legend chips.
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final foreground = isGeneral ? AppColors.white : AppColors.mahabbahRed;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (bold ? 12 : 10).w,
        vertical: 5.h,
      ),
      decoration: ShapeDecoration(
        color: isGeneral ? AppColors.mahabbahRed : AppColors.blush,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: (bold ? 6 : 5).w,
        children: [
          AppSvgIcon(
            isGeneral ? AppIcons.megaphoneGeneral : AppIcons.lockPrivate,
            size: 12.r,
            color: foreground,
          ),
          Flexible(
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                height: 1.3,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.actionRed,
        minimumSize: Size.fromHeight(44.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        side: const BorderSide(color: AppColors.actionRed, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: context.textTheme.labelLarge?.copyWith(fontSize: 14.sp),
      ),
      child: Text(label),
    );
  }
}

/// White message card with a colored stripe along its start edge: dark
/// maroon for general messages, red for private ones.
class _AccentCard extends StatelessWidget {
  const _AccentCard({required this.isGeneral, required this.child});

  final bool isGeneral;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadiusDirectional.only(
      topStart: Radius.circular(4.r),
      topEnd: Radius.circular(18.r),
      bottomStart: Radius.circular(18.r),
      bottomEnd: Radius.circular(18.r),
    );

    // Flutter can't combine a thicker start border with rounded corners, so
    // the stripe is a bar laid over the card and clipped to its shape.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.08),
            offset: Offset(0, 6.h),
            blurRadius: 18.r,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Container(
              // 5 px stripe + 16 px from the start edge, 15 px elsewhere
              // (padding sits inside the 1 px border).
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 14.r, 14.r, 14.r),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.line),
                borderRadius: radius,
              ),
              child: child,
            ),
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              width: 5.w,
              child: ColoredBox(
                color: isGeneral ? AppColors.maroon : AppColors.actionRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
