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
/// beside it. It lies over the top of the list ([collapseExtent] of it) and
/// slides up as older messages are read ([scroll] moves up): the title row
/// drifts up at half speed and fades (parallax) while the picker stays
/// under the status bar. Back at the newest, it opens again.
///
/// Its height never changes, so scrolling lays nothing out again; what's in
/// it is painted once, and only moves.
class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.scroll,
    this.picker,
    this.shortcuts,
  });

  /// The chat's list, newest at offset 0.
  final ScrollController scroll;

  /// Compact. The header keeps its room without it, so it doesn't jump.
  final ChildPicker? picker;
  final ChatShortcuts? shortcuts;

  static const double _parallax = 0.5;

  /// What it gives back as the parent scrolls up: the title row (44 px
  /// buttons) and the gap above the picker.
  static double get collapseExtent => 44.r + 14.h;

  /// Its height slid up: the status bar, the picker and the wave.
  static double collapsedHeight(BuildContext context) =>
      MediaQuery.paddingOf(context).top +
      8.h +
      ChildPicker.compactHeight +
      _bottom;

  /// Room for the wave below the picker.
  static double get _bottom => 36.h;

  /// How far it has slid up for the list's [offset]; open with no list
  /// (loading, empty).
  static double _shrinkOf(ScrollController scroll) =>
      scroll.hasClients ? scroll.offset.clamp(0.0, collapseExtent) : 0.0;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final shortcuts = this.shortcuts;

    final header = RepaintBoundary(
      child: SizedBox(
        height: collapsedHeight(context) + collapseExtent,
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
                  // Its own layer: it moves and fades every frame of the
                  // slide, the rest doesn't.
                  child: RepaintBoundary(
                    child: _CollapsingTitle(
                      scroll: scroll,
                      child: RepaintBoundary(child: _title(context)),
                    ),
                  ),
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
      ),
    );

    return RepaintBoundary(
      child: ListenableBuilder(
        listenable: scroll,
        child: header,
        builder: (context, header) => Transform.translate(
          offset: Offset(0, -_shrinkOf(scroll)),
          child: header,
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

/// The title row as the header slides up: back down by half the slide (so
/// it rises at half speed), fading out, untappable once mostly gone.
class _CollapsingTitle extends StatelessWidget {
  const _CollapsingTitle({required this.scroll, required this.child});

  final ScrollController scroll;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: scroll,
      child: child,
      builder: (context, child) {
        final shrink = ChatHeader._shrinkOf(scroll);
        final collapsed = shrink / ChatHeader.collapseExtent;
        return Transform.translate(
          offset: Offset(0, shrink * ChatHeader._parallax),
          child: IgnorePointer(
            ignoring: collapsed > 0.5,
            child: Opacity(
              opacity: (1 - collapsed * 1.6).clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
