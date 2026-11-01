import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Checkbox with a [label]; tapping either toggles it. 44 px tall so it is
/// easy to hit.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8.r),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 44.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10.w,
          children: [
            SizedBox.square(
              dimension: 20.r,
              child: Checkbox(
                value: value,
                onChanged: (checked) => onChanged(checked ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            Flexible(child: label),
          ],
        ),
      ),
    );
  }
}
