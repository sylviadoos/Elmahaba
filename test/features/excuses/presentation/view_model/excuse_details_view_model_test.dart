import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_details_entity.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excuse_details_event.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excuse_details_state.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excuse_details_view_model.dart';

import '../../../../helpers/result_dummy.dart';
import '../../excuses_fixtures.dart';
import '../../excuses_mocks.mocks.dart';

void main() {
  late MockGetExcuseDetailsUseCase getDetails;
  late MockAddExcuseDocumentsUseCase addDocuments;
  late MockDownloadExcuseDocumentUseCase downloadDocument;
  late MockPreviewExcuseDocumentUseCase previewDocument;

  setUpAll(() {
    provideResultDummy<ExcuseDetailsEntity>();
    provideResultDummy<String>();
  });

  setUp(() {
    getDetails = MockGetExcuseDetailsUseCase();
    addDocuments = MockAddExcuseDocumentsUseCase();
    downloadDocument = MockDownloadExcuseDocumentUseCase();
    previewDocument = MockPreviewExcuseDocumentUseCase();
  });

  ExcuseDetailsViewModel build() => ExcuseDetailsViewModel(
    getDetails,
    addDocuments,
    downloadDocument,
    previewDocument,
  );

  /// Excuse 9 of child 7 opened (it doesn't load: not what's tested here).
  Future<void> open(ExcuseDetailsViewModel model) =>
      model.doAction(const ShowExcuseEvent(childId: 7, excuseId: 9));

  group('documents\' pictures', () {
    blocTest<ExcuseDetailsViewModel, ExcuseDetailsState>(
      'a photo: downloaded to show, a file can still be opened',
      setUp: () => when(
        downloadDocument(7, 9, reportPhoto),
      ).thenAnswer((_) async => const Success(data: '/tmp/311.jpg')),
      build: build,
      act: (model) async {
        await open(model);
        await model.doAction(const LoadExcuseImageEvent(reportPhoto));
      },
      verify: (model) {
        expect(
          model.state.images[311],
          const BaseState.success('/tmp/311.jpg'),
        );
        expect(model.state.downloadingId, isNull);
        verifyNever(previewDocument(any, any, any));
      },
    );

    blocTest<ExcuseDetailsViewModel, ExcuseDetailsState>(
      'a PDF: its first page drawn, the file not opened',
      setUp: () => when(previewDocument(7, 9, reportPdf)).thenAnswer(
        (_) async => const Success(data: '/tmp/310.pdf.preview.png'),
      ),
      build: build,
      act: (model) async {
        await open(model);
        await model.doAction(const LoadExcuseImageEvent(reportPdf));
      },
      verify: (model) {
        expect(
          model.state.images[310],
          const BaseState.success('/tmp/310.pdf.preview.png'),
        );
        expect(model.state.download.state, StateType.initial);
      },
    );

    blocTest<ExcuseDetailsViewModel, ExcuseDetailsState>(
      'didn\'t load: why, to try again',
      setUp: () => when(
        downloadDocument(7, 9, reportPhoto),
      ).thenAnswer((_) async => const Failure(exception: NetworkException())),
      build: build,
      act: (model) async {
        await open(model);
        await model.doAction(const LoadExcuseImageEvent(reportPhoto));
      },
      verify: (model) =>
          expect(model.state.images[311]?.exception, isA<NetworkException>()),
    );

    blocTest<ExcuseDetailsViewModel, ExcuseDetailsState>(
      'before the excuse is open: nothing asked',
      build: build,
      act: (model) => model.doAction(const LoadExcuseImageEvent(reportPhoto)),
      expect: () => <ExcuseDetailsState>[],
      verify: (_) => verifyNever(downloadDocument(any, any, any)),
    );
  });
}
