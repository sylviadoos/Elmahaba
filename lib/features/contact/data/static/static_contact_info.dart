import 'package:al_mahhaba_school/features/contact/data/models/contact_info_model.dart';

// Copied from the school API (GET mobile/contact-us) on Oct 29, 2026.
// Shown while AppConfig.useStaticData is on.
const staticContactInfo = ContactInfoModel(
  title: "Let's Always Be In Touch",
  description:
      'We’re Here for You  For any inquiries or further information, you can '
      'contact us through our various communication channels.',
  address: 'Al-Mahabbah Educational Services, 17 Omar Abdel Aziz St., Assiut',
  phones: ['01222254245', '01222263236'],
  callPhone: '01222263236',
  email: 'admission@almahabbahschools.com',
  mapUrl: 'https://maps.app.goo.gl/BRqzo2DTmePFVtwB6',
  mapEmbedUrl:
      'https://www.google.com/maps/embed?pb=!1m17!1m12!1m3!1d3549.7606418370706'
      '!2d31.190296175448175!3d27.16382027649839!2m3!1f0!2f0!3f0!3m2!1i1024'
      '!2i768!4f13.1!3m2!1m1!2zMjfCsDA5JzQ5LjgiTiAzMcKwMTEnMzQuMyJF!5e0!3m2'
      '!1sen!2seg!4v1752323708645!5m2!1sen!2seg',
  socialLinks: [
    SocialLinkModel(
      platform: 'facebook',
      url: 'https://www.facebook.com/profile.php?id=61578238083712',
    ),
  ],
);
