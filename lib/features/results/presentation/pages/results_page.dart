import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/core/widgets/progress_bar.dart';
import 'package:al_mahhaba_school/core/widgets/section_title.dart';
import 'package:al_mahhaba_school/core/widgets/segmented_control.dart';
import 'package:al_mahhaba_school/features/results/data/mock_results.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/main_nav_bar.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/parent_tab_page.dart';

/// Term results for the selected child: average, subjects and the
/// teacher's note.
class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  int _selectedChild = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final results = mockTerm1Results[_selectedChild];

    return ParentTabPage(
      title: l10n.results,
      tab: MainTab.results,
      selectedChild: _selectedChild,
      onChildSelected: (index) => setState(() => _selectedChild = index),
      children: [
        SegmentedControl(
          options: [
            SegmentOption(l10n.term1),
            SegmentOption(l10n.term2Soon, enabled: false),
          ],
          selected: 0,
          onSelected: (_) {},
        ),
        _AverageCard(results),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.h,
          children: [
            SectionTitle(l10n.subjects),
            for (final subject in results.subjects) _SubjectRow(subject),
          ],
        ),
        _TeacherNote(results.teacherNote),
      ],
    );
  }
}

String _percent(double value) => '${(value * 100).round()}%';

class _AverageCard extends StatelessWidget {
  const _AverageCard(this.results);

  final TermResults results;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        spacing: 16.w,
        children: [
          _AverageRing(results.average),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4.h,
              children: [
                Text(
                  l10n.term1Average,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.slate),
                ),
                Text(
                  results.level,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                    height: 1.2,
                    color: AppColors.mahabbahRed,
                  ),
                ),
                TextButton.icon(
                  // TODO: download the report card PDF.
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.actionRed,
                    minimumSize: Size(0, 40.h),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: AppSvgIcon(AppIcons.download, size: 16.r),
                  label: Text(l10n.reportCardPdf),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Donut showing the average: red share, light rose remainder.
class _AverageRing extends StatelessWidget {
  const _AverageRing(this.value);

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 84.r,
      child: CustomPaint(
        painter: _RingPainter(value),
        child: Center(
          child: Container(
            width: 64.r,
            height: 64.r,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              _percent(value),
              style: context.textTheme.titleLarge?.copyWith(
                fontSize: 19.sp,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas
      ..drawOval(rect, Paint()..color = AppColors.rose)
      ..drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * value,
        true,
        Paint()..color = AppColors.actionRed,
      );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value;
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow(this.subject);

  final SubjectResult subject;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final bold = textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        spacing: 12.w,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.blush,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              subject.short,
              style: textTheme.bodyMedium?.copyWith(
                height: 1,
                fontWeight: FontWeight.w700,
                color: AppColors.mahabbahRed,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6.h,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(subject.name, style: bold)),
                    Text(
                      '${subject.score}/${subject.maxScore}',
                      textDirection: TextDirection.ltr,
                      style: bold?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                ProgressBar(value: subject.fraction),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherNote extends StatelessWidget {
  const _TeacherNote(this.note);

  final String note;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.w,
        children: [
          IconBox(
            AppIcons.navChat,
            size: 38.r,
            iconSize: 18.r,
            radius: 12.r,
            background: AppColors.white,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4.h,
              children: [
                Text(
                  context.l10n.teachersNote,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  note,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
