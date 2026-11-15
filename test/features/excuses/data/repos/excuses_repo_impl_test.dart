import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/pdf/pdf_previewer.dart';
import 'package:al_mahhaba_school/features/excuses/data/data_sources/excuses_remote_data_source.dart';
import 'package:al_mahhaba_school/features/excuses/data/repos/excuses_repo_impl.dart';

import '../../../../helpers/result_matchers.dart';
import '../../excuses_fixtures.dart';
import 'excuses_repo_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ExcusesRemoteDataSource>(),
  MockSpec<PdfPreviewer>(),
])
void main() {
  late MockExcusesRemoteDataSource remoteDataSource;
  late MockPdfPreviewer pdfPreviewer;
  late ExcusesRepoImpl repo;

  setUp(() {
    remoteDataSource = MockExcusesRemoteDataSource();
    pdfPreviewer = MockPdfPreviewer();
    repo = ExcusesRepoImpl(remoteDataSource, pdfPreviewer);
  });

  group('previewDocument', () {
    test('saved, then its first page drawn beside it', () async {
      when(
        remoteDataSource.downloadDocument(7, 9, reportPdf),
      ).thenAnswer((_) async => '/tmp/310_medical-report.pdf');
      when(
        pdfPreviewer.firstPage('/tmp/310_medical-report.pdf'),
      ).thenAnswer((_) async => '/tmp/310_medical-report.pdf.preview.png');

      expect(
        await repo.previewDocument(7, 9, reportPdf),
        isSuccess<Object?>('/tmp/310_medical-report.pdf.preview.png'),
      );
    });

    test('didn\'t download: nothing drawn', () async {
      when(
        remoteDataSource.downloadDocument(7, 9, reportPdf),
      ).thenThrow(const NetworkException());

      expect(
        await repo.previewDocument(7, 9, reportPdf),
        isFailure<NetworkException>(),
      );
      verifyNever(pdfPreviewer.firstPage(any));
    });
  });
}
