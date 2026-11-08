import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_section.dart';

/// A line in a [ChildInfoSection]: [label] and [value].
class ChildInfo {
  const ChildInfo(this.label, this.value, {this.isLtr = false});

  final String label;

  /// Null or empty when the school doesn't have it: the line is left out.
  final String? value;

  /// Codes, phones and emails: left to right in Arabic too.
  final bool isLtr;

  bool get hasValue => value?.isNotEmpty ?? false;
}

/// A card under a title strip (e.g. "FATHER"): a line per [infos] the
/// school has, the label on the start side and the value on the end.
class ChildInfoSection extends StatelessWidget {
  const ChildInfoSection({super.key, required this.title, required this.infos});

  final String title;
  final List<ChildInfo> infos;

  /// Whether any of [infos] has a value: a section without is left out.
  static bool anyIn(List<ChildInfo> infos) =>
      infos.any((info) => info.hasValue);

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final shown = [
      for (final info in infos)
        if (info.hasValue) info,
    ];

    return ComplaintSection(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, info) in shown.indexed)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: index == 0
                  ? null
                  : const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.hairline),
                      ),
                    ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12.w,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      info.label,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.slate,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      info.value!,
                      // In its own language, on the page's end side.
                      textDirection: info.isLtr
                          ? TextDirection.ltr
                          : info.value!.textDirection,
                      textAlign: context.isRtl
                          ? TextAlign.left
                          : TextAlign.right,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
