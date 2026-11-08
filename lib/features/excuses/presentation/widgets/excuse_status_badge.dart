import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_status.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/extensions/excuse_labels.dart';

/// Where an excuse stands, in a pill of its color: blue under review,
/// orange when the school needs more, green accepted, red rejected.
class ExcuseStatusBadge extends StatelessWidget {
  const ExcuseStatusBadge(this.status, {super.key});

  final ExcuseStatus status;

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = status.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Text(
        status.label(context),
        style: context.textTheme.bodySmall?.copyWith(
          fontSize: 12.sp,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
