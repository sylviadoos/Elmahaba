import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// "+20" Egypt country code at the start of a mobile number field
/// (`AppTextField.prefix`).
class CountryCodePrefix extends StatelessWidget {
  const CountryCodePrefix({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: BorderDirectional(
          end: BorderSide(color: AppColors.line, width: 1.5),
        ),
      ),
      child: Text(
        '+20',
        textDirection: TextDirection.ltr,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
