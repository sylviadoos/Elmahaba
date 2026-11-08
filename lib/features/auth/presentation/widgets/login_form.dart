import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/utils/validators.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/app_text_field.dart';
import 'package:al_mahhaba_school/core/widgets/country_code_prefix.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/login_request_entity.dart';

enum _Field { phone, password }

/// The log in form: mobile and password. Checks its fields, then hands
/// them to [onSubmit]. [serverErrors] (keyed by the API's field names) show
/// under their fields until the field is edited.
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.isSending,
    required this.serverErrors,
    required this.onSubmit,
  });

  final bool isSending;
  final Map<String, String> serverErrors;
  final ValueChanged<LoginRequestEntity> onSubmit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final Map<_Field, String> _errors = {};

  static const _apiFields = {
    'phone_number': _Field.phone,
    'password': _Field.password,
  };

  @override
  void didUpdateWidget(LoginForm oldWidget) {
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
    _phone.dispose();
    _password.dispose();
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
      _Field.password: messageOf(Validators.validateRequired(_password.text)),
    };
    setState(() {
      _errors.clear();
      for (final MapEntry(:key, :value) in errors.entries) {
        if (value != null) _errors[key] = value;
      }
    });
    if (_errors.isNotEmpty) return;

    FocusScope.of(context).unfocus();
    widget.onSubmit(LoginRequestEntity(phone: phone, password: _password.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 18.h,
        children: [
          AppTextField(
            label: l10n.mobileNumber,
            hint: l10n.fullPhoneHint,
            controller: _phone,
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
          AppTextField(
            label: l10n.password,
            hint: l10n.enterYourPassword,
            controller: _password,
            prefixIcon: AppIcons.lock,
            isPassword: true,
            errorText: _errors[_Field.password],
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onChanged: (_) => _clearError(_Field.password),
            onSubmitted: (_) => _submit(),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => context.push(AppRoutes.forgotPassword),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.actionRed,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                textStyle: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(l10n.forgotPasswordQuestion),
            ),
          ),
          AppButton(
            label: l10n.login,
            isLoading: widget.isSending,
            onPressed: _submit,
            trailingIcon: AppSvgIcon(
              AppIcons.arrowRight,
              size: 20.r,
              matchTextDirection: true,
            ),
          ),
        ],
      ),
    );
  }
}
