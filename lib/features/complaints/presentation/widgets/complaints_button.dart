import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/header_icon_button.dart';

/// Opens the parent's complaints, from the red header of a parent page.
class ComplaintsButton extends StatelessWidget {
  const ComplaintsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HeaderIconButton(
      icon: AppIcons.complaint,
      tooltip: context.l10n.complaints,
      onPressed: () => context.push(AppRoutes.complaints),
    );
  }
}
