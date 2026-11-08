import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_state.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';

import '../../auth_fixtures.dart';
import '../../auth_mocks.mocks.dart';

void main() {
  late MockGetSavedParentUseCase getSavedParent;

  setUp(() => getSavedParent = MockGetSavedParentUseCase());

  ParentViewModel build() => ParentViewModel(getSavedParent);

  test('starts with no parent', () {
    expect(build().state, const ParentState.initial());
  });

  group('ShowSavedParentEvent', () {
    blocTest<ParentViewModel, ParentState>(
      'a parent is saved: shows them',
      setUp: () => when(getSavedParent()).thenAnswer((_) async => parent),
      build: build,
      act: (viewModel) => viewModel.doAction(const ShowSavedParentEvent()),
      expect: () => [ParentState.success(parent)],
    );

    blocTest<ParentViewModel, ParentState>(
      'none saved: no parent',
      setUp: () => when(getSavedParent()).thenAnswer((_) async => null),
      build: build,
      seed: () => ParentState.success(parent),
      act: (viewModel) => viewModel.doAction(const ShowSavedParentEvent()),
      expect: () => [const ParentState.initial()],
    );
  });

  blocTest<ParentViewModel, ParentState>(
    'ClearParentEvent: forgets the parent shown',
    build: build,
    seed: () => ParentState.success(parent),
    act: (viewModel) => viewModel.doAction(const ClearParentEvent()),
    expect: () => [const ParentState.initial()],
    verify: (_) => verifyZeroInteractions(getSavedParent),
  );
}
