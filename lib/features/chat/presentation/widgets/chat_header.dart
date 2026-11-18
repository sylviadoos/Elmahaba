import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_shortcuts.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_picker.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaints_button.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/settings_button.dart';

/// School chat's red header: back, "School chat" and the school's name,
/// Settings and complaints, then the child [picker] with the [shortcuts]
/// beside it. It stays put as the chat scrolls.
class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key, this.picker, this.shortcuts});

  /// Compact. The header keeps its room without it, so it doesn't jump.
  final ChildPicker? picker;
  final ChatShortcuts? shortcuts;

  /// Room for the wave below the picker.
  static double get _bottom => 36.h;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final shortcuts = this.shortcuts;

    return SizedBox(
      // The status bar, the title row (44 px buttons), the picker, the wave.
      height:
          topInset + 8.h + 44.r + 14.h + ChildPicker.compactHeight + _bottom,
      child: ClipRect(
        child: ColoredBox(
          color: AppColors.mahabbahRed,
          child: Stack(
            children: [
              PositionedDirectional(
                end: -46.w,
                top: topInset + (20 - RedHeader.designStatusBar).h,
                child: const HeaderWatermark(size: Size(200, 143)),
              ),
              Positioned(
                left: 16.w,
                right: 16.w,
                top: topInset + 8.h,
                child: _title(context),
              ),
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: _bottom,
                child: Row(
                  spacing: 8.w,
                  children: [
                    Expanded(child: picker ?? const SizedBox.shrink()),
                    ?shortcuts,
                  ],
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: -1,
                child: HeaderWave(color: AppColors.surface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return Row(
      spacing: 10.w,
      children: [
        const AppBackButton(fallbackRoute: AppRoutes.home),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.schoolChat,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 20.sp,
                  height: 24 / 20,
                  color: AppColors.white,
                ),
              ),
              Text(
                l10n.schoolName,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        const SettingsButton(),
        const ComplaintsButton(),
      ],
    );
  }
}
