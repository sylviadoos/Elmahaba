import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/features/app_version/domain/entities/app_version_entity.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/widgets/update_dialog.dart';

/// What the whole app is while an update is forced: the update card on the
/// brand red, nothing under it to reach. "Update" only.
class ForcedUpdateView extends StatelessWidget {
  const ForcedUpdateView({
    super.key,
    required this.update,
    required this.onUpdate,
  });

  final AppVersionEntity update;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: AppColors.mahabbahRed,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: UpdateDialog(update: update, onUpdate: onUpdate),
            ),
          ),
        ),
      ),
    );
  }
}
