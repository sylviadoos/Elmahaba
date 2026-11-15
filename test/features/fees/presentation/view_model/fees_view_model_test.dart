import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/use_cases/change_optional_fee_use_case.dart';
import 'package:al_mahhaba_school/features/fees/domain/use_cases/get_fee_statement_use_case.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/fees_event.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/fees_view_model.dart';

import '../../../../helpers/result_dummy.dart';
import '../../fees_fixtures.dart';
import 'fees_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GetFeeStatementUseCase>(),
  MockSpec<ChangeOptionalFeeUseCase>(),
])
const _childId = 9;

void main() {
  late MockGetFeeStatementUseCase getStatement;
  late MockChangeOptionalFeeUseCase changeOptionalFee;
  late FeesViewModel viewModel;

  final shown = statement();

  setUpAll(() {
    provideResultDummy<FeeStatementEntity>();
    provideResultDummy<void>();
  });

  setUp(() {
    getStatement = MockGetFeeStatementUseCase();
    changeOptionalFee = MockChangeOptionalFeeUseCase();
    when(getStatement(any)).thenAnswer((_) async => Success(data: shown));
    when(
      changeOptionalFee(
        childId: anyNamed('childId'),
        feeId: anyNamed('feeId'),
        add: anyNamed('add'),
      ),
    ).thenAnswer((_) async => const Success<void>(data: null));
    viewModel = FeesViewModel(getStatement, changeOptionalFee);
  });

  tearDown(() => viewModel.close());

  Future<void> loadStatement() =>
      viewModel.doAction(const LoadFeesEvent(_childId));

  Future<void> change({required bool add}) => viewModel.doAction(
    ChangeOptionalFeeEvent(childId: _childId, feeId: busFeeId, add: add),
  );

  test('adding an optional fee: the school is asked, then the statement '
      'is loaded again', () async {
    await loadStatement();
    clearInteractions(getStatement);

    await change(add: true);

    verify(
      changeOptionalFee(childId: _childId, feeId: busFeeId, add: true),
    ).called(1);
    // The fee moves between the lines and the totals change with it.
    verify(getStatement(_childId)).called(1);
    expect(viewModel.state.changingFeeId, isNull);
    expect(viewModel.state.changeFailed, isNull);
  });

  test('dropping one asks the school to drop it', () async {
    await loadStatement();

    await change(add: false);

    verify(
      changeOptionalFee(childId: _childId, feeId: busFeeId, add: false),
    ).called(1);
  });

  test('the school turned it down: it says why, and nothing reloads', () async {
    await loadStatement();
    clearInteractions(getStatement);
    when(
      changeOptionalFee(
        childId: anyNamed('childId'),
        feeId: anyNamed('feeId'),
        add: anyNamed('add'),
      ),
    ).thenAnswer(
      (_) async => const Failure<void>(exception: NetworkException()),
    );

    await change(add: true);

    expect(viewModel.state.changeFailed, isA<NetworkException>());
    expect(viewModel.state.changingFeeId, isNull);
    // What was on screen stays on screen.
    expect(viewModel.state.statement.data, shown);
    verifyNever(getStatement(any));
  });

  test('a second tap while the first is on its way is ignored', () async {
    await loadStatement();

    await Future.wait([change(add: true), change(add: true)]);

    verify(
      changeOptionalFee(
        childId: anyNamed('childId'),
        feeId: anyNamed('feeId'),
        add: anyNamed('add'),
      ),
    ).called(1);
  });

  test('a change that failed is forgotten when the next one starts', () async {
    await loadStatement();
    when(
      changeOptionalFee(
        childId: anyNamed('childId'),
        feeId: anyNamed('feeId'),
        add: anyNamed('add'),
      ),
    ).thenAnswer(
      (_) async => const Failure<void>(exception: NetworkException()),
    );
    await change(add: true);
    expect(viewModel.state.changeFailed, isNotNull);

    when(
      changeOptionalFee(
        childId: anyNamed('childId'),
        feeId: anyNamed('feeId'),
        add: anyNamed('add'),
      ),
    ).thenAnswer((_) async => const Success<void>(data: null));
    await change(add: true);

    expect(viewModel.state.changeFailed, isNull);
  });

  test("couldn't load the statement: the error shows", () async {
    when(
      getStatement(any),
    ).thenAnswer((_) async => const Failure(exception: NetworkException()));

    await loadStatement();

    expect(viewModel.state.statement.state, StateType.error);
  });
}
