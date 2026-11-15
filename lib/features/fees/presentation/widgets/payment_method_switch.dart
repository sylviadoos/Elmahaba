import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// Outlined pill with two choices, the picked one filled red: pay the full
/// amount, or in installments.
class PaymentMethodSwitch extends StatelessWidget {
  const PaymentMethodSwitch({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: const ShapeDecoration(
        shape: StadiumBorder(side: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        spacing: 4.w,
        children: [
          for (final (index, label) in labels.indexed)
            Expanded(
              child: Semantics(
                selected: index == selected,
                child: Material(
                  color: index == selected
                      ? AppColors.actionRed
                      : Colors.transparent,
                  shape: const StadiumBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: index == selected ? null : () => onSelected(index),
                    child: SizedBox(
                      height: 48.h,
                      child: Center(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            height: 16 / 14,
                            fontWeight: FontWeight.w600,
                            color: index == selected
                                ? AppColors.white
                                : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
