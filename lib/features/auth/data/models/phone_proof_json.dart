import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';

extension PhoneProofJson on PhoneProofEntity {
  /// The proof's field in a request body: Firebase's token, or the code
  /// the school texted.
  Map<String, dynamic> toJson() => switch (this) {
    FirebaseProof(:final idToken) => {'firebase_id_token': idToken},
    SchoolCodeProof(:final code) => {'otp': code},
  };
}
