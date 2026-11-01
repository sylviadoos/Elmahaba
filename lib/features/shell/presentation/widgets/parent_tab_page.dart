import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/child_tabs.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/children/data/mock_children.dart';
import 'package:al_mahhaba_school/features/home/data/mock_home.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/main_nav_bar.dart';

/// Frame of the Results / Attendance / Fees tabs: red header with the
/// [title] and child switcher, scrolling [children], and the nav bar.
class ParentTabPage extends StatelessWidget {
  const ParentTabPage({
    super.key,
    required this.title,
    required this.tab,
    required this.selectedChild,
    required this.onChildSelected,
    required this.children,
  });

  final String title;
  final MainTab tab;
  final int selectedChild;
  final ValueChanged<int> onChildSelected;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final navBottom = math.max(24.h, MediaQuery.paddingOf(context).bottom + 8);
    final chatUnread = mockDashboards.fold(0, (sum, d) => sum + d.unread);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RedHeader(
                  horizontalPadding: 16,
                  bottomPadding: 36,
                  watermarkTop: 20,
                  watermarkSize: const Size(200, 143),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12.h,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          title,
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontSize: 26.sp,
                            height: 44 / 26,
                            letterSpacing: 0,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      ChildTabs(
                        tabs: [
                          for (final child in mockChildren)
                            ChildTab(name: child.firstName, grade: child.grade),
                        ],
                        selected: selectedChild,
                        onSelected: onChildSelected,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    // Bottom room so the last item scrolls above the nav bar.
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      6.h,
                      20.w,
                      navBottom + 68.h + 24.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 18.h,
                      children: children,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: navBottom,
              child: MainNavBar(current: tab, chatUnread: chatUnread),
            ),
          ],
        ),
      ),
    );
  }
}
