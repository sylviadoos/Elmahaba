import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// Six boxes, one per digit, over an invisible text field that takes the
/// typing (so paste and SMS autofill work). The next box to fill is
/// highlighted while the field is focused.
class OtpCodeInput extends StatefulWidget {
  const OtpCodeInput({
    super.key,
    required this.controller,
    this.length = 6,
    this.onChanged,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onChanged;

  @override
  State<OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<OtpCodeInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_refresh);
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _focusNode.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final code = widget.controller.text;

    // Digits always read left to right, in Arabic too.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Row(
            spacing: 8.w,
            children: [
              for (var i = 0; i < widget.length; i++)
                Expanded(
                  child: _DigitBox(
                    digit: i < code.length ? code[i] : '',
                    isFilled: i < code.length,
                    isActive: _focusNode.hasFocus && i == code.length,
                  ),
                ),
            ],
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                onChanged: widget.onChanged,
                showCursor: false,
                enableInteractiveSelection: false,
                expands: true,
                maxLines: null,
                decoration: const InputDecoration.collapsed(hintText: null),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.digit,
    required this.isFilled,
    required this.isActive,
  });

  final String digit;
  final bool isFilled;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final borderColor = isActive
        ? AppColors.actionRed
        : isFilled
        ? AppColors.ink
        : AppColors.line;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 58.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive || isFilled ? AppColors.white : AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isActive
            ? const [BoxShadow(color: AppColors.rose, spreadRadius: 4)]
            : null,
      ),
      child: Text(
        digit,
        style: context.textTheme.titleLarge?.copyWith(
          fontSize: 24.sp,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
