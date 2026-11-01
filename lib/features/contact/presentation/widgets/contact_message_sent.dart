import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';

/// "Message sent!" with a Done button back to the Contact page.
class ContactMessageSent extends StatelessWidget {
  const ContactMessageSent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return StateMessage(
      icon: AppIcons.check,
      iconBackground: AppColors.successBg,
      iconColor: AppColors.success,
      title: l10n.messageSentTitle,
      subtitle: l10n.messageSentSubtitle,
      action: AppButton(
        label: l10n.done,
        expand: false,
        onPressed: () => context.pop(),
      ),
    );
  }
}
