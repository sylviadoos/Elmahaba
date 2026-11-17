import 'package:flutter/material.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';

/// What an `AppToast` says: done, careful, or failed — its colour and icon.
enum AppToastType {
  success(AppColors.success, Icons.check_rounded),
  warning(AppColors.warning, Icons.priority_high_rounded),
  error(AppColors.error, Icons.close_rounded);

  const AppToastType(this.color, this.icon);

  final Color color;
  final IconData icon;
}
