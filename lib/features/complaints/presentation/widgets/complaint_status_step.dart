import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_status_change_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/complaint_labels.dart';

/// One step of a complaint's status history, newest at the top: a dot in
/// the status' color for the [latest], grey for the rest, joined by a line
/// to the step under it unless it's the [last].
class ComplaintStatusStep extends StatelessWidget {
  const ComplaintStatusStep({
    super.key,
    required this.change,
    required this.latest,
    required this.last,
  });

  final ComplaintStatusChangeEntity change;
  final bool latest;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final at = change.at;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12.w,
        children: [
          Column(
            children: [
              Container(
                width: 12.r,
                height: 12.r,
                margin: EdgeInsets.only(top: 4.h),
                decoration: BoxDecoration(
                  color: latest ? change.status.colors.$2 : AppColors.separator,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  constraints: BoxConstraints(minHeight: 18.h),
                  color: last ? Colors.transparent : AppColors.line,
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2.h,
                children: [
                  Text(
                    change.status.label(context),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (at != null)
                    Text(
                      at.dateTimeLabel(context),
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        height: 16 / 12,
                        color: AppColors.slate,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
