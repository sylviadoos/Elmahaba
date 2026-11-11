import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/results/data/data_sources/results_remote_data_source_impl.dart';

import '../../results_fixtures.dart';
import 'results_remote_data_source_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ApiService>()])
void main() {
  late MockApiService api;
  late ResultsRemoteDataSourceImpl dataSource;

  setUp(() {
    api = MockApiService();
    dataSource = ResultsRemoteDataSourceImpl(api);
  });

  group('getMonthlyResults', () {
    test('asks for the monthly template, reads the example', () async {
      when(
        api.get(
          ApiEndpoints.childResultSheets(146),
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer((_) async => monthlyJson);

      final results = await dataSource.getMonthlyResults(146);

      verify(
        api.get(
          'v1/parent/children/146/result-sheets',
          queryParameters: {'template': 'monthly'},
        ),
      ).called(1);
      expect(results.sheets.map((sheet) => sheet.id), [341, 326]);
      expect(results.sheets.first.month, 'November');
      expect(results.sheets.first.display, 'value and color');
      expect(results.sheets.first.publishedAt, DateTime.utc(2026, 12, 5, 10));

      final certificate = results.certificate!;
      expect(certificate.studentName, 'Omar Ahmed');
      expect(certificate.studentNameAr, 'عمر أحمد');
      expect(certificate.grade, 'First Primary');
      expect(certificate.className, 'A');

      final october = certificate.months.first;
      expect(october.key, 'm0');
      expect(october.month, 'October');
      expect(october.grandTotal, 245);
      expect(october.maxGrandTotal, 280);
      expect(october.percentage, 87.5);
      expect(october.rank, 3);
      expect(october.attendancePercentage, 96);

      final [arabic, religion, math] = certificate.subjects;
      expect(arabic.includedInTotal, isTrue);
      expect(arabic.components.first.name, 'Monthly exam');
      expect(arabic.components.first.max, 15);
      expect(arabic.marks['m0']?.components['Weekly assessment'], 9);
      expect(arabic.marks['m1']?.total, 39);
      expect(religion.includedInTotal, isFalse);
      expect(religion.marks.keys, ['m0']);
      // No marks yet: nothing, rather than a failure.
      expect(math.includedInTotal, isNull);
      expect(math.components, isEmpty);
      expect(math.marks, isEmpty);
    });

    test('no certificate: just the sheets', () async {
      when(
        api.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenAnswer((_) async => {'status': 'success', 'data': []});

      final results = await dataSource.getMonthlyResults(146);

      expect(results.sheets, isEmpty);
      expect(results.certificate, isNull);
      expect(results.hasMonths, isFalse);
    });

    test('fails: the error goes on', () {
      when(
        api.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenThrow(const NetworkException());

      expect(
        dataSource.getMonthlyResults(146),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
