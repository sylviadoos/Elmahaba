import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/utils/validators.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_checkbox.dart';
import 'package:al_mahhaba_school/core/widgets/app_text_field.dart';
import 'package:al_mahhaba_school/core/widgets/country_code_prefix.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/password_rules.dart';

enum _Field { phone, password, passwordConfirmation }

/// The sign-up form: mobile, password twice and the terms. The password
/// is checked against the same [PasswordRule]s as a reset one, as it is
/// typed, and Create account waits for them. Then the fields go to
/// [onSubmit]. [serverErrors] (keyed by the API's field names) show under
/// their fields until the field is edited.
class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
    required this.isSending,
    required this.serverErrors,
    required this.onSubmit,
  });

  final bool isSending;
  final Map<String, String> serverErrors;
  final ValueChanged<RegisterRequestEntity> onSubmit;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();
  bool _agreed = false;
  final Map<_Field, String> _errors = {};

  static const _apiFields = {
    'phone_number': _Field.phone,
    'password': _Field.password,
    'password_confirmation': _Field.passwordConfirmation,
  };

  @override
  void didUpdateWidget(RegisterForm oldWidget) {
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
    for (final controller in [_phone, _password, _passwordConfirmation]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _clearError(_Field field) {
    if (_errors.containsKey(field)) setState(() => _errors.remove(field));
  }

  void _submit() {
    String? messageOf(ValidationError? error) => error?.message(context);
    final phone = _phone.text;

    final errors = <_Field, String?>{
      _Field.phone: messageOf(Validators.validatePhoneNumber(phone)),
      _Field.password: messageOf(Validators.validatePassword(_password.text)),
      _Field.passwordConfirmation: messageOf(
        Validators.validateConfirmPassword(
          password: _password.text,
          confirmPassword: _passwordConfirmation.text,
        ),
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
      RegisterRequestEntity(
        phone: phone,
        password: _password.text,
        passwordConfirmation: _passwordConfirmation.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final password = _password.text;
    final confirmation = _passwordConfirmation.text;
    const linkStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.actionRed,
    );

    AppTextField passwordField(
      _Field field,
      TextEditingController controller,
      String label,
      String hint,
      TextInputAction action,
    ) => AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      height: 52,
      labelGap: 6,
      errorText: _errors[field],
      isPassword: true,
      textInputAction: action,
      autofillHints: const [AutofillHints.newPassword],
      // The rules follow what is typed; the field's error goes with it.
      onChanged: (_) => setState(() => _errors.remove(field)),
    );

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12.h,
        children: [
          AppTextField(
            label: l10n.mobileNumber,
            hint: l10n.fullPhoneHint,
            controller: _phone,
            height: 52,
            labelGap: 6,
            prefix: const CountryCodePrefix(code: '+2'),
            errorText: _errors[_Field.phone],
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              // The full 11 digits after +2: 010 1234 5678.
              LengthLimitingTextInputFormatter(11),
            ],
            onChanged: (_) => _clearError(_Field.phone),
          ),
          passwordField(
            _Field.password,
            _password,
            l10n.password,
            l10n.passwordHint,
            TextInputAction.next,
          ),
          passwordField(
            _Field.passwordConfirmation,
            _passwordConfirmation,
            l10n.confirmPassword,
            l10n.confirmPasswordHint,
            TextInputAction.done,
          ),
          PasswordRules(password: password, confirmation: confirmation),
          AppCheckbox(
            value: _agreed,
            onChanged: (value) => setState(() => _agreed = value),
            label: Text.rich(
              TextSpan(
                text: l10n.agreePrefix,
                children: [
                  // TODO: open the Terms / Privacy Policy pages.
                  TextSpan(text: l10n.terms, style: linkStyle),
                  TextSpan(text: l10n.agreeAnd),
                  TextSpan(text: l10n.privacyPolicy, style: linkStyle),
                ],
              ),
            ),
          ),
          AppButton(
            label: l10n.createAccount,
            isLoading: widget.isSending,
            // Enabled once the rules are met and the terms accepted.
            onPressed: _agreed && PasswordRule.allMet(password, confirmation)
                ? _submit
                : null,
          ),
        ],
      ),
    );
  }
}
