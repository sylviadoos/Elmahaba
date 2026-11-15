import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_view_model.dart';

import '../../../../helpers/result_dummy.dart';
import '../../children_fixtures.dart';
import '../../children_mocks.mocks.dart';

void main() {
  late MockVerifyChildLinkUseCase verifyChildLink;
  late MockResendChildLinkCodeUseCase resendCode;
  late LinkChildCodeViewModel viewModel;

  setUpAll(() {
    provideResultDummy<ChildEntity>();
    provideResultDummy<LinkVerificationEntity>();
  });

  setUp(() {
    verifyChildLink = MockVerifyChildLinkUseCase();
    resendCode = MockResendChildLinkCodeUseCase();
    viewModel = LinkChildCodeViewModel(verifyChildLink, resendCode);
  });

  tearDown(() => viewModel.close());

  test('the right code: the child, linked', () async {
    when(
      verifyChildLink(token: verification.token, code: '123456'),
    ).thenAnswer((_) async => const Success(data: ereny));

    await viewModel.doAction(
      CheckLinkCodeEvent(token: verification.token, code: '123456'),
    );

    expect(viewModel.state.checking.data, ereny);
  });

  test('a wrong code: the school\'s error', () async {
    when(
      verifyChildLink(token: anyNamed('token'), code: anyNamed('code')),
    ).thenAnswer(
      (_) async =>
          const Failure(exception: ServerException(code: 'otp_incorrect')),
    );

    await viewModel.doAction(
      CheckLinkCodeEvent(token: verification.token, code: '000000'),
    );

    expect(viewModel.state.checking.state, StateType.error);
    expect(
      (viewModel.state.checking.exception! as ServerException).code,
      'otp_incorrect',
    );
  });

  test('another code: the check as sent again', () async {
    when(
      resendCode(verification.token),
    ).thenAnswer((_) async => Success(data: verification));

    await viewModel.doAction(ResendLinkCodeEvent(verification.token));

    expect(viewModel.state.resending.data, verification);
  });

  test('one at a time: nothing else is sent while a code is checked', () async {
    final answer = Completer<Result<ChildEntity>>();
    when(
      verifyChildLink(token: anyNamed('token'), code: anyNamed('code')),
    ).thenAnswer((_) => answer.future);

    unawaited(
      viewModel.doAction(
        CheckLinkCodeEvent(token: verification.token, code: '123456'),
      ),
    );
    await viewModel.doAction(
      CheckLinkCodeEvent(token: verification.token, code: '654321'),
    );
    await viewModel.doAction(ResendLinkCodeEvent(verification.token));
    answer.complete(const Success(data: ereny));
    await Future<void>.delayed(Duration.zero);

    verify(
      verifyChildLink(token: anyNamed('token'), code: anyNamed('code')),
    ).called(1);
    verifyNever(resendCode(any));
  });
}
