import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';

/// Centered icon and text for a page's empty, error and done states. In
/// place of a whole list, see [CenteredStateMessage].
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    this.iconBackground = AppColors.blush,
    this.iconColor = AppColors.mahabbahRed,
    required this.title,
    this.subtitle,
    this.action,
    this.topPadding = 56,
  });

  final String icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String? subtitle;

  /// e.g. a "Try again" button.
  final Widget? action;

  /// Room above it, in design pixels.
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final subtitle = this.subtitle;
    final action = this.action;

    return Padding(
      padding: EdgeInsets.only(top: topPadding.h),
      child: Column(
        children: [
          IconBox(
            icon,
            size: 64.r,
            iconSize: 28.r,
            circle: true,
            background: iconBackground,
            color: iconColor,
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 18.sp,
              color: AppColors.ink,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: AppColors.slate,
              ),
            ),
          ],
          if (action != null) ...[SizedBox(height: 20.h), action],
        ],
      ),
    );
  }
}

/// A [StateMessage] in place of a whole list (none yet, or why it didn't
/// load): in the middle of all the room it's given, below [top] (e.g.
/// under a header lying over the list). It still scrolls when there's too
/// little room, and can be pulled down to refresh.
class CenteredStateMessage extends StatelessWidget {
  const CenteredStateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.top = 0,
  });

  final String icon;
  final String title;
  final String? subtitle;

  /// e.g. a "Try again" button.
  final Widget? action;

  /// Logical pixels kept clear above it.
  final double top;

  @override
  Widget build(BuildContext context) {
    // The same above and below, so it's in the very middle.
    final gap = 24.h;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, top + gap, 20.w, gap),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.max(0, constraints.maxHeight - top - 2 * gap),
          ),
          child: Center(
            child: StateMessage(
              icon: icon,
              title: title,
              subtitle: subtitle,
              action: action,
              // Centered: no room above it of its own.
              topPadding: 0,
            ),
          ),
        ),
      ),
    );
  }
}
