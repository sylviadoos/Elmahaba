import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/core/utils/validators.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_select_field.dart';
import 'package:al_mahhaba_school/core/widgets/app_text_field.dart';
import 'package:al_mahhaba_school/core/widgets/country_code_prefix.dart';
import 'package:al_mahhaba_school/features/contact/domain/entities/contact_message_entity.dart';
import 'package:al_mahhaba_school/features/contact/presentation/extensions/contact_option_labels.dart';

enum _Field { firstName, lastName, phone, email, message }

/// The "Send us a message" form. Checks its fields, then hands the message
/// to [onSubmit]. [serverErrors] (keyed by the API's field names) show
/// under their fields until the field is edited.
class ContactMessageForm extends StatefulWidget {
  const ContactMessageForm({
    super.key,
    required this.isSending,
    required this.serverErrors,
    required this.onSubmit,
  });

  final bool isSending;
  final Map<String, String> serverErrors;
  final ValueChanged<ContactMessageEntity> onSubmit;

  @override
  State<ContactMessageForm> createState() => _ContactMessageFormState();
}

class _ContactMessageFormState extends State<ContactMessageForm> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  EducationType? _educationType;
  SchoolStage? _stage;
  final Map<_Field, String> _errors = {};

  static const _apiFields = {
    'first_name': _Field.firstName,
    'last_name': _Field.lastName,
    'phone': _Field.phone,
    'email': _Field.email,
    'message': _Field.message,
  };

  static const _maxNameLength = 100;
  static const _maxMessageLength = 2000;

  @override
  void didUpdateWidget(ContactMessageForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.serverErrors, oldWidget.serverErrors)) {
      for (final MapEntry(:key, :value) in widget.serverErrors.entries) {
        final field = _apiFields[key];
        if (field != null) _errors[field] = value;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _phone,
      _email,
      _message,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _clearError(_Field field) {
    if (_errors.containsKey(field)) setState(() => _errors.remove(field));
  }

  void _submit() {
    String? messageOf(ValidationError? error) => error?.message(context);
    final phone = _phone.text.localPhone;
    final email = _email.text.trim();

    final errors = <_Field, String?>{
      _Field.firstName: messageOf(Validators.validateName(_firstName.text)),
      _Field.lastName: messageOf(Validators.validateName(_lastName.text)),
      _Field.phone: messageOf(Validators.validatePhoneNumber(phone)),
      _Field.email: email.isEmpty
          ? null
          : messageOf(Validators.validateEmail(email)),
      _Field.message: messageOf(
        Validators.validateRequired(_message.text.trim()),
      ),
    };
    setState(() {
      _errors.clear();
      for (final MapEntry(:key, :value) in errors.entries) {
        if (value != null) _errors[key] = value;
      }
    });
    if (_errors.isNotEmpty) return;

    FocusScope.of(context).unfocus();
    widget.onSubmit(
      ContactMessageEntity(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        educationType: _educationType,
        stage: _stage,
        phone: phone,
        email: email,
        message: _message.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const optional = _OptionalTag();

    AppTextField nameField(
      _Field field,
      TextEditingController controller,
      String label,
      String hint,
      String autofill,
    ) => AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      height: 52,
      labelGap: 6,
      errorText: _errors[field],
      textInputAction: TextInputAction.next,
      autofillHints: [autofill],
      inputFormatters: [LengthLimitingTextInputFormatter(_maxNameLength)],
      onChanged: (_) => _clearError(field),
    );

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14.h,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12.w,
            children: [
              Expanded(
                child: nameField(
                  _Field.firstName,
                  _firstName,
                  l10n.firstName,
                  l10n.firstNameHint,
                  AutofillHints.givenName,
                ),
              ),
              Expanded(
                child: nameField(
                  _Field.lastName,
                  _lastName,
                  l10n.lastName,
                  l10n.lastNameHint,
                  AutofillHints.familyName,
                ),
              ),
            ],
          ),
          AppTextField(
            label: l10n.mobileNumber,
            hint: l10n.phoneHint,
            controller: _phone,
            height: 52,
            labelGap: 6,
            prefix: const CountryCodePrefix(),
            errorText: _errors[_Field.phone],
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              // 10 digits after +20, or 11 when typed with the leading 0.
              LengthLimitingTextInputFormatter(11),
            ],
            onChanged: (_) => _clearError(_Field.phone),
          ),
          AppTextField(
            label: l10n.email,
            labelTrailing: optional,
            hint: l10n.emailHint,
            controller: _email,
            height: 52,
            labelGap: 6,
            errorText: _errors[_Field.email],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) => _clearError(_Field.email),
          ),
          AppSelectField<EducationType>(
            label: l10n.educationType,
            labelTrailing: optional,
            hint: l10n.chooseEducationType,
            height: 52,
            labelGap: 6,
            options: EducationType.values,
            value: _educationType,
            optionLabel: (type) => type.label(l10n),
            onChanged: (type) => setState(() => _educationType = type),
          ),
          AppSelectField<SchoolStage>(
            label: l10n.schoolStage,
            labelTrailing: optional,
            hint: l10n.chooseStage,
            height: 52,
            labelGap: 6,
            options: SchoolStage.values,
            value: _stage,
            optionLabel: (stage) => stage.label(l10n),
            onChanged: (stage) => setState(() => _stage = stage),
          ),
          AppTextField(
            label: l10n.yourMessage,
            hint: l10n.messageHint,
            controller: _message,
            minLines: 5,
            labelGap: 6,
            errorText: _errors[_Field.message],
            textInputAction: TextInputAction.newline,
            inputFormatters: [
              LengthLimitingTextInputFormatter(_maxMessageLength),
            ],
            onChanged: (_) => _clearError(_Field.message),
          ),
          SizedBox(height: 4.h),
          AppButton(
            label: l10n.sendMessage,
            isLoading: widget.isSending,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

/// Grey "Optional" at the end of a field's label.
class _OptionalTag extends StatelessWidget {
  const _OptionalTag();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.optional,
      style: context.textTheme.bodySmall?.copyWith(color: AppColors.mist),
    );
  }
}
