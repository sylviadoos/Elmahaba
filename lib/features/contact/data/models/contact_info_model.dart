import 'package:al_mahhaba_school/features/contact/domain/entities/contact_info_entity.dart';

/// [ContactInfoEntity] read from `GET mobile/contact-us`.
class ContactInfoModel extends ContactInfoEntity {
  const ContactInfoModel({
    required super.title,
    required super.description,
    required super.address,
    required super.phones,
    super.callPhone,
    required super.email,
    super.mapUrl,
    super.mapEmbedUrl,
    required super.socialLinks,
  });

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) =>
      ContactInfoModel(
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phones: [
          for (final phone in json['phones'] as List<dynamic>? ?? [])
            phone as String,
        ],
        callPhone: json['call'] as String?,
        email: json['email'] as String? ?? '',
        mapUrl: json['map_url'] as String?,
        mapEmbedUrl: json['map_embed_url'] as String?,
        socialLinks: [
          for (final link in json['social_links'] as List<dynamic>? ?? [])
            SocialLinkModel.fromJson(link as Map<String, dynamic>),
        ],
      );
}

class SocialLinkModel extends SocialLinkEntity {
  const SocialLinkModel({required super.platform, required super.url});

  factory SocialLinkModel.fromJson(Map<String, dynamic> json) =>
      SocialLinkModel(
        platform: (json['platform'] as String).toLowerCase(),
        url: json['url'] as String,
      );
}
