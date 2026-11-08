import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/header_icon_button.dart';

/// Opens Settings (and from there the parent's profile), from the red
/// header of a parent page.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HeaderIconButton(
      icon: AppIcons.settings,
      tooltip: context.l10n.settings,
      onPressed: () => context.push(AppRoutes.settings),
    );
  }
}
