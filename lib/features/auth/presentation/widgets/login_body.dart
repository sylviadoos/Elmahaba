import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/auth_field_errors.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/login_locked.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_state.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/login_form.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';

/// The [LoginForm] wired to the [AuthViewModel] above it: logs in, then
/// opens Home, or shows what went wrong. Locked after too many wrong
/// passwords: the time left counts down instead.
class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  /// The number last sent: the one a lock is for.
  String? _sentPhone;
  LoginLock? _lock;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthViewModel, AuthState>(
      listenWhen: (_, state) =>
          state.state == StateType.success || state.state == StateType.error,
      listener: (context, state) {
        if (state.data is LoggedIn) {
          // Log in saved the parent and their children: show them.
          context.read<ParentViewModel>().doAction(
            const ShowSavedParentEvent(),
          );
          context.read<ChildrenViewModel>().doAction(
            const ShowSavedChildrenEvent(),
          );
          context.go(AppRoutes.home);
          return;
        }

        final exception = state.exception!;
        // Locked: the time left counts down above Log in, from what the
        // school says is left — not its fixed "in 15 minutes".
        final lockedFor = exception.loginLockedFor;
        final phone = _sentPhone;
        if (lockedFor != null && phone != null) {
          setState(
            () => _lock = (phone: phone, until: clock.now().add(lockedFor)),
          );
          return;
        }

        // invalid_credentials, phone_not_registered… come with the
        // server's message, in the app's language.
        // TODO: a "contact the school" sheet (school_contact) for
        // phone_not_registered — its message shows here for now.
        context.showSnackBar(
          exception.authFieldErrors.isNotEmpty
              ? context.l10n.checkHighlightedFields
              : exception.localizedMessage(context),
          isError: true,
        );
      },
      builder: (context, state) => LoginForm(
        isSending: state.state == StateType.loading,
        serverErrors: state.exception.authFieldErrors,
        lock: _lock,
        onSubmit: (request) {
          _sentPhone = request.phone;
          context.read<AuthViewModel>().doAction(LoginEvent(request));
        },
      ),
    );
  }
}
