import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_picker.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaints_button.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/settings_button.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/main_nav_bar.dart';

/// Frame of the Results / Attendance / Fees tabs: red header with back
/// (to Home), the [title], Profile and Complaints, and the child picker, and scrolling
/// [children]. The nav bar is
/// `ParentShellPage`'s, over it.
///
/// The picker shows the parent's real children; [selectedChild] is the one
/// every page shows (`watchSelectedChildIndex`).
class ParentTabPage extends StatelessWidget {
  const ParentTabPage({
    super.key,
    required this.title,
    required this.selectedChild,
    required this.onChildSelected,
    required this.children,
  });

  final String title;
  final int selectedChild;
  final ValueChanged<int> onChildSelected;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final parentChildren = context.watchChildren();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
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
                  Row(
                    spacing: 8.w,
                    children: [
                      // A tab is the first page of its own: back is Home.
                      const AppBackButton(fallbackRoute: AppRoutes.home),
                      Expanded(
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
                      const SettingsButton(),
                      const ComplaintsButton(),
                    ],
                  ),
                  if (parentChildren.isNotEmpty)
                    ChildPicker(
                      children: parentChildren,
                      selected: selectedChild,
                      onSelected: onChildSelected,
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  6.h,
                  20.w,
                  MainNavBar.contentPadding(context),
                ),
                // Painted once: scrolling only moves it, rather than paint
                // every card again each frame.
                child: RepaintBoundary(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 18.h,
                    children: children,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
