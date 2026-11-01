import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/utils/external_links.dart';
import 'package:al_mahhaba_school/features/contact/domain/entities/contact_info_entity.dart';

/// Grey button that opens one of the school's social pages.
class ContactSocialButton extends StatelessWidget {
  const ContactSocialButton(this.link, {super.key});

  final SocialLinkEntity link;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ExternalLinks.open(context, ExternalLinks.web(link.url)),
        child: SizedBox(
          height: 44.h,
          child: Center(
            child: Text(
              _displayName(link.platform),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// "facebook" → "Facebook", "youtube" → "YouTube".
  static String _displayName(String platform) => switch (platform) {
    'facebook' => 'Facebook',
    'instagram' => 'Instagram',
    'youtube' => 'YouTube',
    'x' || 'twitter' => 'X',
    'tiktok' => 'TikTok',
    'linkedin' => 'LinkedIn',
    'whatsapp' => 'WhatsApp',
    '' => platform,
    _ => platform[0].toUpperCase() + platform.substring(1),
  };
}
