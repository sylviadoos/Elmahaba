import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/children/data/models/link_child_result_model.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_result_entity.dart';

import '../../children_fixtures.dart';

void main() {
  test('a code texted to the child\'s phone: the check, as sent', () {
    final result = LinkChildResultModel.fromJson(const {
      'result': 'otp_required',
      'verification': verificationJson,
    });

    expect(result, isA<ChildLinkCodeSent>());
    final sent = (result as ChildLinkCodeSent).verification;
    expect(sent.token, '9b1f4c2e-6a7d-4e1b-8c3f-2d5a6b7c8d9e');
    expect(sent.maskedPhone, '••• ••• 4567');
    expect(sent.relationship, 'father');
    expect(sent.expiresIn, const Duration(minutes: 5));
    expect(sent.resendAfter, const Duration(seconds: 60));
    expect(sent.resendsLeft, 3);
  });

  test('pending: as before', () {
    expect(
      LinkChildResultModel.fromJson(const {
        'result': 'pending_review',
        'request_id': 15,
      }),
      const ChildLinkPending(15),
    );
  });

  test('a result this app doesn\'t know: fails', () {
    expect(
      () => LinkChildResultModel.fromJson(const {'result': 'something'}),
      throwsFormatException,
    );
  });
}
