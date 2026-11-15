import 'package:al_mahhaba_school/features/children/data/models/child_model.dart';
import 'package:al_mahhaba_school/features/children/data/models/link_verification_model.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';

/// The API's example `verification` of a link that needs a texted code.
const verificationJson = <String, dynamic>{
  'verification_token': '9b1f4c2e-6a7d-4e1b-8c3f-2d5a6b7c8d9e',
  'masked_phone': '••• ••• 4567',
  'relationship': 'father',
  'expires_in': 300,
  'resend_after': 60,
  'resends_left': 3,
};

final LinkVerificationEntity verification = LinkVerificationModel.fromJson(
  verificationJson,
);

/// The child linked once the code is right.
const ereny = ChildModel(
  studentId: 1202,
  name: 'ereny ebram',
  nameAr: 'ايريني ابرام',
  nationalId: '••••1010',
  relationship: 'father',
  access: 'active',
  grade: 'KG1',
  className: 'A',
  academicYear: '2026-2027',
);
