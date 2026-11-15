import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
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
  late ChildrenViewModel viewModel;

  setUpAll(() {
    provideResultDummy<List<ChildEntity>>();
    provideResultDummy<LinkChildResultEntity>();
  });

  setUp(() {
    getSaved = MockGetSavedChildrenUseCase();
    getChildren = MockGetChildrenUseCase();
    linkChild = MockLinkChildUseCase();
    viewModel = ChildrenViewModel(getSaved, getChildren, linkChild);
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
}
