import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// What a new password needs. [differentFromCurrent] only when changing it
/// (the current one is known).
enum PasswordRule {
  eightCharacters,
  letter,
  number,
  match,
  differentFromCurrent;

  /// The rules that apply: all of them when there's a [current] password.
  static List<PasswordRule> forPassword({String? current}) => [
    for (final rule in values)
      if (rule != differentFromCurrent || current != null) rule,
  ];

  bool isMet(String password, String confirmation, {String? current}) =>
      switch (this) {
        eightCharacters => password.length >= 8,
        // English or Arabic.
        letter => RegExp(r'[A-Za-z؀-ۿ]').hasMatch(password),
        number => RegExp(r'\d').hasMatch(password),
        match => password.isNotEmpty && password == confirmation,
        differentFromCurrent => password.isNotEmpty && password != current,
      };

  /// [changing]: there's also the current password, so "both new" ones
  /// must match.
  String label(AppLocalizations l10n, {required bool changing}) =>
      switch (this) {
        eightCharacters => l10n.ruleEightCharacters,
        letter => l10n.ruleHasLetter,
        number => l10n.ruleHasNumber,
        match =>
          changing ? l10n.ruleNewPasswordsMatch : l10n.rulePasswordsMatch,
        differentFromCurrent => l10n.ruleDifferentFromCurrent,
      };

  static bool allMet(String password, String confirmation, {String? current}) =>
      forPassword(
        current: current,
      ).every((rule) => rule.isMet(password, confirmation, current: current));
}

/// The [PasswordRule]s, each turning green with a check once met. With a
/// [currentPassword], the new one must differ from it too.
class PasswordRules extends StatelessWidget {
  const PasswordRules({
    super.key,
    required this.password,
    required this.confirmation,
    this.currentPassword,
  });

  final String password;
  final String confirmation;
  final String? currentPassword;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = currentPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6.h,
      children: [
        for (final rule in PasswordRule.forPassword(current: current))
          Row(
            spacing: 8.w,
            children: [
              Container(
                width: 18.r,
                height: 18.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rule.isMet(password, confirmation, current: current)
                      ? AppColors.success
                      : AppColors.unmet,
                  shape: BoxShape.circle,
                ),
                child: AppSvgIcon(
                  AppIcons.check,
                  size: 11.r,
                  color: AppColors.white,
                ),
              ),
              Expanded(
                child: Text(
                  rule.label(l10n, changing: current != null),
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 13.sp,
                    color: rule.isMet(password, confirmation, current: current)
                        ? AppColors.success
                        : AppColors.slate,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
