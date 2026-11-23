import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// Text field from the designs: a label above, and a rounded grey box that
/// turns white with a red border and a soft ring while focused.
///
/// Optional extras: an icon or [prefix] (e.g. a "+20" country code) inside
/// the box, a show/hide toggle for passwords, an [action] next to the box
/// (e.g. an "Add" button), and a helper or error line below.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.labelTrailing,
    this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.isPassword = false,
    this.showPasswordToggle = true,
    this.prefixIcon,
    this.prefix,
    this.action,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.height = 54,
    this.minLines = 1,
    this.labelGap = 8,
    this.labelWeight = FontWeight.w500,
    this.letterSpacing,
    this.fillColor = AppColors.surface,
  });

  final String? label;

  /// Shown at the end of the label row, e.g. a "7 / 14" counter.
  final Widget? labelTrailing;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPassword;
  final bool showPasswordToggle;

  /// Icon asset shown at the start of the box.
  final String? prefixIcon;

  /// Custom widget at the start of the box (instead of an icon).
  final Widget? prefix;

  /// Widget placed next to the box, outside it.
  final Widget? action;
  final String? helperText;

  /// Shown below the box in red; also turns the border red.
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Design values, in pixels.
  final double height;

  /// More than 1 makes a multi-line box (e.g. a message) that starts this
  /// many lines tall and grows with the text; [height] is then ignored.
  final int minLines;
  final double labelGap;

  /// Most designs label fields at 500; a few at 600.
  final FontWeight labelWeight;
  final double? letterSpacing;

  /// The box's color while not focused: grey, or white on a grey card.
  final Color fillColor;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  late bool _obscure = widget.isPassword;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final focused = _focusNode.hasFocus;
    final hasError = widget.errorText != null;
    final showToggle = widget.isPassword && widget.showPasswordToggle;
    final multiline = widget.minLines > 1;
    final inputStyle = textTheme.bodyLarge?.copyWith(
      height: multiline ? 1.4 : 1.25,
      letterSpacing: widget.letterSpacing,
    );

    // The whole box counts as the field: the password toggle and the
    // padding around the text don't put the keyboard away.
    Widget box = TextFieldTapRegion(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: multiline ? null : widget.height.h,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsetsDirectional.only(
          start: widget.prefix == null
              ? (widget.prefixIcon == null ? 16 : 14).w
              : 0,
          end: showToggle ? 6.w : 16.w,
          top: multiline ? 14.h : 0,
          bottom: multiline ? 14.h : 0,
        ),
        decoration: BoxDecoration(
          color: focused ? AppColors.white : widget.fillColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasError
                ? AppColors.error
                : focused
                ? AppColors.actionRed
                : AppColors.line,
            width: 1.5,
          ),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: hasError
                        ? AppColors.error.withValues(alpha: 0.15)
                        : AppColors.rose,
                    spreadRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: multiline
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (widget.prefix != null) ...[
              widget.prefix!,
              SizedBox(width: 14.w),
            ],
            if (widget.prefixIcon != null) ...[
              AppSvgIcon(
                widget.prefixIcon!,
                size: 20.r,
                color: AppColors.slate,
              ),
              SizedBox(width: 10.w),
            ],
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                controller: widget.controller,
                keyboardType:
                    widget.keyboardType ??
                    (multiline ? TextInputType.multiline : null),
                minLines: widget.minLines,
                maxLines: multiline ? widget.minLines + 4 : 1,
                textInputAction: widget.textInputAction,
                autofillHints: widget.autofillHints,
                inputFormatters: widget.inputFormatters,
                obscureText: _obscure,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                // Done typing: a tap anywhere else puts the keyboard away. A
                // box of several lines has no key for it (Enter is a new
                // line), and on a phone Flutter leaves it up otherwise.
                onTapOutside: (_) => _focusNode.unfocus(),
                style: inputStyle,
                // The outer box draws the border and fill, so switch off every
                // state the app's input theme would add.
                decoration: InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: widget.hint,
                  hintStyle: inputStyle?.copyWith(color: AppColors.placeholder),
                ),
              ),
            ),
            if (showToggle)
              IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                tooltip: _obscure
                    ? context.l10n.showPassword
                    : context.l10n.hidePassword,
                style: IconButton.styleFrom(
                  fixedSize: Size.square(44.r),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                icon: AppSvgIcon(
                  _obscure ? AppIcons.eye : AppIcons.eyeOff,
                  size: 20.r,
                  color: AppColors.slate,
                ),
              ),
          ],
        ),
      ),
    );

    if (widget.action != null) {
      box = Row(
        spacing: 8.w,
        children: [
          Expanded(child: box),
          widget.action!,
        ],
      );
    }

    final note = widget.errorText ?? widget.helperText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: widget.labelGap.h,
      children: [
        if (widget.label != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.label!,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: widget.labelWeight,
                  ),
                ),
              ),
              ?widget.labelTrailing,
            ],
          ),
        box,
        if (note != null)
          Text(
            note,
            style: textTheme.bodySmall?.copyWith(
              color: hasError ? AppColors.error : AppColors.slate,
            ),
          ),
      ],
    );
  }
}
