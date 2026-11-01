import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/contact/domain/entities/contact_info_entity.dart';
import 'package:al_mahhaba_school/features/contact/domain/use_cases/get_contact_info_use_case.dart';
import 'package:al_mahhaba_school/features/contact/presentation/view_model/contact_event.dart';

typedef ContactState = BaseState<ContactInfoEntity>;

/// Drives the Contact page. No navigation actions, hence `void`.
@injectable
class ContactViewModel extends BaseCubit<ContactState, ContactEvent, void> {
  ContactViewModel(this._getContactInfo) : super(const ContactState.initial());

  final GetContactInfoUseCase _getContactInfo;

  @override
  Future<void> doAction(ContactEvent event) async {
    switch (event) {
      case GetContactInfoEvent():
        await _loadContactInfo();
    }
  }

  Future<void> _loadContactInfo() async {
    emit(const ContactState.loading());
    final result = await _getContactInfo();
    if (isClosed) return;
    emit(
      result.when(
        success: (info) => ContactState.success(info),
        failure: (exception) => ContactState.error(exception),
      ),
    );
  }
}
