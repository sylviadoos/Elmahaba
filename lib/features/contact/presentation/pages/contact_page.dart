import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/utils/external_links.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/equal_height_grid.dart';
import 'package:al_mahhaba_school/core/widgets/section_title.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/core/widgets/visitor_header.dart';
import 'package:al_mahhaba_school/core/widgets/visitor_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/parent_context.dart';
import 'package:al_mahhaba_school/features/contact/domain/entities/contact_info_entity.dart';
import 'package:al_mahhaba_school/features/contact/presentation/view_model/contact_event.dart';
import 'package:al_mahhaba_school/features/contact/presentation/view_model/contact_view_model.dart';
import 'package:al_mahhaba_school/features/contact/presentation/widgets/contact_address_card.dart';
import 'package:al_mahhaba_school/features/contact/presentation/widgets/contact_skeleton.dart';
import 'package:al_mahhaba_school/features/contact/presentation/widgets/contact_social_button.dart';
import 'package:al_mahhaba_school/features/contact/presentation/widgets/contact_tile.dart';
import 'package:al_mahhaba_school/features/contact/presentation/widgets/contact_website_note.dart';

/// Address, phone numbers, email and social pages, from the API.
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider(
      create: (_) =>
          getIt<ContactViewModel>()..doAction(const GetContactInfoEvent()),
      child: VisitorPage(
        header: VisitorHeader(
          title: l10n.contactUs,
          subtitle: l10n.contactSubtitle,
        ),
        // Also opened from Profile, where the parent is already signed in.
        showLogin: context.watchParent() == null,
        children: const [_ContactBody()],
      ),
    );
  }
}

class _ContactBody extends StatelessWidget {
  const _ContactBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactViewModel, ContactState>(
      builder: (context, state) => state.when(
        initial: () => const ContactSkeleton(),
        loading: () => const ContactSkeleton(),
        error: (exception) => StateMessage(
          icon: AppIcons.info,
          title: exception.localizedMessage(context),
          action: AppButton(
            label: context.l10n.tryAgain,
            outlined: true,
            expand: false,
            onPressed: () => context.read<ContactViewModel>().doAction(
              const GetContactInfoEvent(),
            ),
          ),
        ),
        success: (info) => _ContactDetails(info),
      ),
    );
  }
}

class _ContactDetails extends StatelessWidget {
  const _ContactDetails(this.info);

  final ContactInfoEntity info;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final socialLinks = info.socialLinks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24.h,
      children: [
        ContactAddressCard(address: info.address, mapUrl: info.mapUrl),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.h,
          children: [
            SectionTitle(l10n.callOrEmail),
            for (final phone in info.phones)
              ContactTile(
                icon: AppIcons.phone,
                iconBackground: AppColors.successBg,
                iconColor: AppColors.success,
                label: l10n.phone,
                value: _formatPhone(phone),
                onTap: () =>
                    ExternalLinks.open(context, ExternalLinks.phone(phone)),
              ),
            if (info.email.isNotEmpty)
              ContactTile(
                icon: AppIcons.mail,
                iconBackground: AppColors.blush,
                iconColor: AppColors.mahabbahRed,
                label: l10n.admission,
                value: info.email,
                valueSize: 14,
                onTap: () => ExternalLinks.open(
                  context,
                  ExternalLinks.email(info.email),
                ),
              ),
            // The form sends through the API, so it waits for it.
            if (!AppConfig.useStaticData)
              ContactTile(
                icon: AppIcons.edit,
                iconBackground: AppColors.goldSoft,
                iconColor: AppColors.goldDeep,
                label: l10n.writeToUs,
                value: l10n.sendMessage,
                valueIsLtr: false,
                onTap: () => context.push(AppRoutes.contactMessage),
              ),
          ],
        ),
        if (socialLinks.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10.h,
            children: [
              SectionTitle(l10n.followUs),
              EqualHeightGrid(
                // Up to 4 per row; fewer links share the full width.
                columns: math.min(socialLinks.length, 4),
                spacing: 8.w,
                children: [
                  for (final link in socialLinks) ContactSocialButton(link),
                ],
              ),
            ],
          ),
        const ContactWebsiteNote(),
      ],
    );
  }

  /// "01222254245" → "0122 225 4245"; other formats are shown as sent.
  static String _formatPhone(String phone) {
    final digits = phone.replaceAll(' ', '');
    if (digits.length != 11 || !digits.startsWith('01')) return phone;
    return '${digits.substring(0, 4)} ${digits.substring(4, 7)} '
        '${digits.substring(7)}';
  }
}
