import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/fees/domain/fees_error_codes.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/pay_online_message.dart';

void main() {
  /// [exception]'s message, as Pay fees shows it.
  Future<String> shown(WidgetTester tester, AppException exception) async {
    late String message;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            message = exception.payOnlineMessage(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return message;
  }

  testWidgets('paid out of order: the school\'s sentence naming the fee', (
    tester,
  ) async {
    // The school's answer to the bus before the education installments.
    const exception = ServerException(
      statusCode: 422,
      code: FeesErrorCodes.payOnlineInstallmentOrder,
      message: 'Earlier installments must be paid first.',
      body: {
        'status': 'error',
        'code': FeesErrorCodes.payOnlineInstallmentOrder,
        'message': 'Earlier installments must be paid first.',
        'website_message':
            'يجب دفع مصاريف التعليم والنشاط أولاً قبل دفع مصاريف الباص.',
      },
    );

    expect(
      await shown(tester, exception),
      'يجب دفع مصاريف التعليم والنشاط أولاً قبل دفع مصاريف الباص.',
    );
  });

  testWidgets('out of order, no sentence: the server\'s message', (
    tester,
  ) async {
    const exception = ServerException(
      statusCode: 422,
      code: FeesErrorCodes.payOnlineInstallmentOrder,
      message: 'Earlier installments must be paid first.',
      body: {'website_message': ' '},
    );

    expect(
      await shown(tester, exception),
      'Earlier installments must be paid first.',
    );
  });

  testWidgets('any other error: the server\'s message', (tester) async {
    const exception = ServerException(
      statusCode: 502,
      code: FeesErrorCodes.payOnlineUnavailable,
      message:
          'تعذر بدء عملية الدفع الإلكتروني. برجاء المحاولة مرة أخرى لاحقًا.',
      body: {'website_message': 'not this'},
    );

    expect(
      await shown(tester, exception),
      'تعذر بدء عملية الدفع الإلكتروني. برجاء المحاولة مرة أخرى لاحقًا.',
    );
  });
}
