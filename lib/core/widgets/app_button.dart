import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Primary button with a built-in loading state.
///
/// Full width by default; set [expand] to false for a button that fits its
/// label (e.g. "Next" next to a page counter). [outlined] gives the white,
/// bordered secondary style ("Continue as guest").
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.expand = true,
    this.outlined = false,
  });

  final String label;

  /// Null disables the button (grey).
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Shown before the label.
  final Widget? icon;

  /// Shown after the label, e.g. an arrow.
  final Widget? trailingIcon;
  final bool expand;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final onPressed = isLoading ? null : this.onPressed;
    final child = isLoading
        ? SizedBox.square(
            dimension: 22.r,
            child: const CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, SizedBox(width: 10.w)],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              if (trailingIcon != null) ...[
                SizedBox(width: 10.w),
                trailingIcon!,
              ],
            ],
          );

    final button = outlined
        ? OutlinedButton(onPressed: onPressed, child: child)
        : ElevatedButton(onPressed: onPressed, child: child);

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
