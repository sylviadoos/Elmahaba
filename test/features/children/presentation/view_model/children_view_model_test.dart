import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/children/data/models/child_model.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_request_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_result_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';

import '../../../../helpers/result_dummy.dart';
import '../../children_fixtures.dart';
import '../../children_mocks.mocks.dart';

void main() {
  late MockGetSavedChildrenUseCase getSaved;
  late MockGetChildrenUseCase getChildren;
  late MockLinkChildUseCase linkChild;
  late MockGetSelectedChildUseCase getSelected;
  late MockSaveSelectedChildUseCase saveSelected;
  late ChildrenViewModel viewModel;

  setUpAll(() {
    provideResultDummy<List<ChildEntity>>();
    provideResultDummy<LinkChildResultEntity>();
  });

  setUp(() {
    getSaved = MockGetSavedChildrenUseCase();
    getChildren = MockGetChildrenUseCase();
    linkChild = MockLinkChildUseCase();
    getSelected = MockGetSelectedChildUseCase();
    saveSelected = MockSaveSelectedChildUseCase();
    viewModel = ChildrenViewModel(
      getSaved,
      getChildren,
      linkChild,
      getSelected,
      saveSelected,
    );
  });

  tearDown(() => viewModel.close());

  test(
    'a code texted to the child\'s phone: the check, nothing linked yet',
    () async {
      when(
        linkChild(any),
      ).thenAnswer((_) async => Success(data: ChildLinkCodeSent(verification)));

      await viewModel.doAction(
        const LinkChildEvent(
          LinkChildRequestEntity(nationalId: '30101010101010'),
        ),
      );

      expect(viewModel.state.link.data, ChildLinkCodeSent(verification));
      verifyNever(getChildren());
    },
  );

  test(
    'the code entered: linked, shown at once, the list asked again',
    () async {
      when(getChildren()).thenAnswer((_) async => const Success(data: [ereny]));
      viewModel.emit(const ChildrenState(children: BaseState.success([])));

      await viewModel.doAction(const ChildLinkVerifiedEvent(ereny));

      expect(viewModel.state.link.data, const ChildLinked(ereny));
      expect(viewModel.state.children.data, [ereny]);
      verify(getChildren()).called(1);
    },
  );

  group('the child picked, kept when the app closes', () {
    /// Ereny and her brother, saved from the last launch.
    const brother = ChildModel(
      studentId: 1203,
      name: 'mina ebram',
      nameAr: 'مينا ابرام',
      nationalId: '••••1203',
      relationship: 'father',
      access: 'active',
      grade: 'Second Primary',
      className: 'A',
      academicYear: '2026-2027',
    );

    setUp(() {
      when(getSaved()).thenAnswer((_) async => [ereny, brother]);
      when(
        getChildren(),
      ).thenAnswer((_) async => const Success(data: [ereny, brother]));
    });

    test('picked: kept for the next launch', () async {
      await viewModel.doAction(const SelectChildEvent(1203));

      expect(viewModel.state.selectedId, 1203);
      verify(saveSelected(1203)).called(1);
    });

    test('opened again: the one picked last shows, not the first', () async {
      when(getSelected()).thenAnswer((_) async => 1203);

      await viewModel.doAction(const LoadChildrenEvent());

      expect(viewModel.state.selectedChild, brother);
    });

    test('right after log in, too', () async {
      when(getSelected()).thenAnswer((_) async => 1203);

      await viewModel.doAction(const ShowSavedChildrenEvent());

      expect(viewModel.state.selectedChild, brother);
    });

    test('never picked: the first', () async {
      when(getSelected()).thenAnswer((_) async => null);

      await viewModel.doAction(const LoadChildrenEvent());

      expect(viewModel.state.selectedChild, ereny);
    });

    test('no longer on the account: the first', () async {
      when(getSelected()).thenAnswer((_) async => 4040);

      await viewModel.doAction(const LoadChildrenEvent());

      expect(viewModel.state.selectedChild, ereny);
    });

    test('one picked while it was read (a notification tapped): '
        'that one stands', () async {
      when(getSelected()).thenAnswer((_) async {
        // Picked while the phone was still reading the one kept.
        await viewModel.doAction(const SelectChildEvent(1202));
        return 1203;
      });

      await viewModel.doAction(const LoadChildrenEvent());

      expect(viewModel.state.selectedChild, ereny);
    });

    test("the phone can't keep it: still picked, nothing breaks", () async {
      when(saveSelected(any)).thenThrow(Exception('storage locked'));

      await viewModel.doAction(const SelectChildEvent(1203));

      expect(viewModel.state.selectedId, 1203);
    });
  });
}
