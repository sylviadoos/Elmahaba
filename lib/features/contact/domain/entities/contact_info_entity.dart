import 'package:equatable/equatable.dart';

/// The school's contact details.
class ContactInfoEntity extends Equatable {
  const ContactInfoEntity({
    required this.title,
    required this.description,
    required this.address,
    required this.phones,
    this.callPhone,
    required this.email,
    this.mapUrl,
    this.mapEmbedUrl,
    required this.socialLinks,
  });

  /// e.g. "Let's Always Be In Touch"
  final String title;
  final String description;
  final String address;

  /// e.g. "01222254245"
  final List<String> phones;

  /// The number to call first, if the school set one.
  final String? callPhone;
  final String email;

  /// Opens the school's location in Google Maps.
  final String? mapUrl;

  /// Google Maps embed link (for a WebView).
  final String? mapEmbedUrl;
  final List<SocialLinkEntity> socialLinks;

  @override
  List<Object?> get props => [
    title,
    description,
    address,
    phones,
    callPhone,
    email,
    mapUrl,
    mapEmbedUrl,
    socialLinks,
  ];
}

class SocialLinkEntity extends Equatable {
  const SocialLinkEntity({required this.platform, required this.url});

  /// Lowercase name, e.g. "facebook".
  final String platform;
  final String url;

  @override
  List<Object?> get props => [platform, url];
}
