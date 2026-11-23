import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_text_field.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_images_viewer.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/attachment_picker.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_error_alert.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/new_excuse_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/excuses_error_codes.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/excuse_args.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/extensions/excuse_labels.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/new_excuse_event.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/new_excuse_view_model.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/widgets/excuse_absence_card.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/widgets/excuse_documents_field.dart';

/// A medical excuse for one absence: a note and the documents. Pops the
/// excuse once the school has it; pops nothing when the day can't take one
/// any more (Attendance then shows why).
class NewExcusePage extends StatelessWidget {
  const NewExcusePage({super.key, required this.args});

  final NewExcuseArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NewExcuseViewModel>(),
      child: _NewExcuseView(args: args),
    );
  }
}

class _NewExcuseView extends StatefulWidget {
  const _NewExcuseView({required this.args});

  final NewExcuseArgs args;

  @override
  State<_NewExcuseView> createState() => _NewExcuseViewState();
}

class _NewExcuseViewState extends State<_NewExcuseView> {
  /// Over the day's state, the school no longer takes one for it: back to
  /// Attendance, which loads it again.
  static const Set<String> _dayClosed = {
    ExcusesErrorCodes.windowClosed,
    ExcusesErrorCodes.alreadyActive,
    ExcusesErrorCodes.notEligible,
    ExcusesErrorCodes.recordNotFound,
    ExcusesErrorCodes.readOnlyChild,
    ExcusesErrorCodes.childNotAvailable,
  };

  final TextEditingController _note = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<PickedAttachment> _documents = [];

  /// "Submit" was tapped without a document.
  bool _tried = false;

  /// Why the school didn't take it, over the form.
  String? _alert;

  @override
  void dispose() {
    _note.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _pickDocuments() async {
    final picked = await context.pickAttachments(
      picked: _documents.length,
      limits: widget.args.rules.limits,
    );
    if (mounted) setState(() => _documents.addAll(picked));
  }

  void _submit() {
    context.hideKeyboard();
    if (_documents.isEmpty) {
      setState(() => _tried = true);
      return;
    }
    setState(() => _alert = null);
    context.read<NewExcuseViewModel>().doAction(
      SubmitExcuseEvent(
        childId: widget.args.childId,
        excuse: NewExcuseEntity(
          attendanceId: widget.args.absence.attendanceId,
          note: _note.text.trim(),
          documents: [for (final file in _documents) file.path],
        ),
      ),
    );
  }

  void _onError(AppException exception) {
    final message = exception.localizedMessage(context);
    if (exception is UnauthorizedException) {
      context.showSnackBar(message, isError: true);
      context.logOut();
      return;
    }
    if (exception case ServerException(
      :final code?,
    ) when _dayClosed.contains(code)) {
      context.showSnackBar(message, isError: true);
      _back();
      return;
    }
    final fieldErrors = exception is ServerException
        ? exception.fieldErrors
        : const <String, String>{};
    setState(() => _alert = fieldErrors.values.firstOrNull ?? message);
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Attendance is under this page, unless it was opened another way.
  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.attendance);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final args = widget.args;
    final alert = _alert;

    return BlocConsumer<NewExcuseViewModel, NewExcuseState>(
      listener: (context, state) {
        if (state.state == StateType.success) {
          context.showSnackBar(l10n.excuseSent);
          context.pop(state.data);
        }
        if (state.state == StateType.error) _onError(state.exception!);
      },
      builder: (context, state) {
        final isSending = state.state == StateType.loading;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RedHeader(
                  horizontalPadding: 16,
                  bottomPadding: 40,
                  watermarkTop: 20,
                  watermarkSize: const Size(200, 143),
                  child: Row(
                    spacing: 10.w,
                    children: [
                      const AppBackButton(fallbackRoute: AppRoutes.attendance),
                      Expanded(
                        child: Text(
                          l10n.medicalExcuse,
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 24.sp,
                            height: 1.25,
                            letterSpacing: 0,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      4.h,
                      20.w,
                      math.max(40.h, MediaQuery.paddingOf(context).bottom + 16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 20.h,
                      children: [
                        if (alert != null) ComplaintErrorAlert(alert),
                        ExcuseAbsenceCard(absence: args.absence),
                        AppTextField(
                          label: '${l10n.excuseNote} ${l10n.optionalNote}',
                          labelWeight: FontWeight.w600,
                          hint: l10n.excuseNoteHint,
                          controller: _note,
                          minLines: 3,
                        ),
                        ExcuseDocumentsField(
                          files: _documents,
                          limits: args.rules.limits,
                          onAdd: isSending ? null : _pickDocuments,
                          onRemove: isSending
                              ? null
                              : (index) =>
                                    setState(() => _documents.removeAt(index)),
                          onPreview: (index) => context.previewPickedPhotos(
                            _documents,
                            _documents[index],
                          ),
                          errorText: _tried && _documents.isEmpty
                              ? l10n.excuseDocumentRequired
                              : null,
                        ),
                        AppButton(
                          label: l10n.submitExcuse,
                          isLoading: isSending,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
