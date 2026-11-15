import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';

/// Red header: back and "Settings".
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return RedHeader(
      horizontalPadding: 16,
      bottomPadding: 40,
      watermarkTop: 20,
      watermarkSize: const Size(200, 143),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppBackButton(fallbackRoute: AppRoutes.home),
          Text(
            context.l10n.settings,
            style: context.textTheme.titleLarge?.copyWith(
              color: AppColors.white,
            ),
          ),
          // As wide as back, so the title stays centred.
          SizedBox(width: 44.r),
        ],
      ),
    );
  }
}
