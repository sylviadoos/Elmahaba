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
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/child_display.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/complaints/domain/complaints_error_codes.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/attachment_picker.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/complaint_labels.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/new_complaint_event.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/new_complaint_state.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/new_complaint_view_model.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_attachments_field.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_category_field.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_choice_group.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_error_alert.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_sent_card.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/settings_button.dart';

/// A new complaint: its category, which child (or General), what happened
/// and any files. Once sent, its reference, and on to it or back to
/// Complaints.
class NewComplaintPage extends StatelessWidget {
  const NewComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<NewComplaintViewModel>()
            ..doAction(const LoadComplaintCategoriesEvent()),
      child: const _NewComplaintView(),
    );
  }
}

class _NewComplaintView extends StatefulWidget {
  const _NewComplaintView();

  @override
  State<_NewComplaintView> createState() => _NewComplaintViewState();
}

class _NewComplaintViewState extends State<_NewComplaintView> {
  /// The fields' names in the API's errors.
  static const String _categoryField = 'category_id';
  static const String _descriptionField = 'description';

  final TextEditingController _description = TextEditingController();
  final ScrollController _scroll = ScrollController();

  /// The picked category's id.
  int? _categoryId;

  /// The child it's about (their position in the parent's children); null
  /// for General.
  int? _about = 0;

  /// With the ones that won't be sent, which say why.
  List<PickedAttachment> _attachments = [];

  /// "Submit" was tapped: the fields left empty say so.
  bool _tried = false;

  /// What the school found wrong with a field, until it's changed.
  String? _categoryError;
  String? _descriptionError;

  /// Why the school didn't take it, over the form.
  String? _alert;

  @override
  void dispose() {
    _description.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _pickAttachments() async {
    final picked = await context.pickComplaintAttachments(
      current: _attachments,
    );
    if (mounted) setState(() => _attachments = [..._attachments, ...picked]);
  }

  void _loadCategories() => context.read<NewComplaintViewModel>().doAction(
    const LoadComplaintCategoriesEvent(),
  );

  void _submit({required int? categoryId, required int? studentId}) {
    context.hideKeyboard();
    final description = _description.text.trim();
    if (categoryId == null || description.isEmpty) {
      setState(() => _tried = true);
      _scrollToTop();
      return;
    }
    setState(() => _alert = null);
    context.read<NewComplaintViewModel>().doAction(
      SendComplaintEvent(
        categoryId: categoryId,
        studentId: studentId,
        description: description,
        // The ones that can't go stay on screen, saying why.
        attachments: [for (final file in _attachments.valid) file.path],
      ),
    );
  }

  /// A field's problem goes under it, any other over the form.
  void _onSendError(AppException exception) {
    if (exception is UnauthorizedException) {
      context.showSnackBar(exception.localizedMessage(context), isError: true);
      context.logOut();
      return;
    }
    if (exception case ServerException(
      code: ComplaintsErrorCodes.fileRejected,
      :final body,
    )) {
      final name = body['file_name'];
      // Its row says so; take it off and send again.
      if (_attachments.any((file) => file.isValid && file.name == name)) {
        setState(() => _attachments = _attachments.rejecting('$name'));
        return;
      }
    }
    final fieldErrors = exception is ServerException
        ? exception.fieldErrors
        : const <String, String>{};
    final otherErrors = [
      for (final MapEntry(:key, :value) in fieldErrors.entries)
        if (key != _categoryField && key != _descriptionField) value,
    ];
    setState(() {
      _categoryError = fieldErrors[_categoryField];
      _descriptionError = fieldErrors[_descriptionField];
      _alert =
          otherErrors.firstOrNull ??
          // The server's own message only asks to check the fields.
          (fieldErrors.isEmpty ? exception.localizedMessage(context) : null);
    });
    if (exception case ServerException(
      code: ComplaintsErrorCodes.categoryNotAvailable,
    )) {
      setState(() => _categoryId = null);
      _loadCategories();
    }
    _scrollToTop();
  }

  void _scrollToTop() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Complaints is under this page, unless it was opened another way.
  void _backToComplaints() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.complaints);

  /// In this page's place, so going back from it leads to Complaints.
  void _viewComplaint(ComplaintEntity sent) => context.pushReplacement(
    AppRoutes.complaintDetailsOf(sent.id),
    extra: sent,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return BlocConsumer<NewComplaintViewModel, NewComplaintState>(
      listenWhen: (previous, current) =>
          previous.sending.state != current.sending.state,
      listener: (context, state) {
        if (state.sending.state == StateType.error) {
          _onSendError(state.sending.exception!);
        }
      },
      builder: (context, state) {
        final sent = state.sending.state == StateType.success
            ? state.sending.data
            : null;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12.h,
                    children: [
                      Row(
                        spacing: 10.w,
                        children: [
                          const AppBackButton(
                            fallbackRoute: AppRoutes.complaints,
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                l10n.newComplaint,
                                style: textTheme.headlineMedium?.copyWith(
                                  fontSize: 24.sp,
                                  height: 1.25,
                                  letterSpacing: 0,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          const SettingsButton(),
                        ],
                      ),
                      Text(
                        l10n.complaintPrivacyNote,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.88),
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
                    child: sent == null
                        ? _form(context, state)
                        : ComplaintSentCard(
                            reference: sent.referenceLabel,
                            status: sent.status.label(context),
                            onViewComplaint: () => _viewComplaint(sent),
                            onBackToComplaints: _backToComplaints,
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

  Widget _form(BuildContext context, NewComplaintState state) {
    final l10n = context.l10n;
    final children = context.watchChildren();
    final isSending = state.sending.state == StateType.loading;
    // General when there are no children (yet), or fewer than before.
    final about = _about == null || children.isEmpty
        ? null
        : children.clampSelection(_about!);
    // None picked while the categories reload, or once it's gone.
    final categoryId =
        state.categories.data?.any((category) => category.id == _categoryId) ==
            true
        ? _categoryId
        : null;
    final alert = _alert;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20.h,
      children: [
        if (alert != null) ComplaintErrorAlert(alert),
        ComplaintCategoryField(
          categories: state.categories,
          selected: categoryId,
          onSelected: (id) => setState(() {
            _categoryId = id;
            _categoryError = null;
          }),
          onRetry: _loadCategories,
          errorText:
              _categoryError ??
              (_tried && categoryId == null ? l10n.categoryRequired : null),
        ),
        ComplaintChoiceGroup<int?>(
          label: l10n.complaintAbout,
          options: [
            for (final (index, child) in children.indexed)
              (index, child.firstName(context)),
            (null, l10n.complaintGeneral),
          ],
          selected: about,
          onSelected: (index) => setState(() => _about = index),
          hint: l10n.complaintGeneralHint,
        ),
        AppTextField(
          label: l10n.complaintDescription,
          labelWeight: FontWeight.w600,
          hint: l10n.complaintDescriptionHint,
          controller: _description,
          minLines: 5,
          errorText:
              _descriptionError ??
              (_tried && _description.text.trim().isEmpty
                  ? l10n.descriptionRequired
                  : null),
          onChanged: (_) => setState(() => _descriptionError = null),
        ),
        ComplaintAttachmentsField(
          files: _attachments,
          upload: isSending
              ? state.upload ?? (sent: 0, total: _attachments.validBytes)
              : null,
          onAdd: isSending ? null : _pickAttachments,
          onRemove: isSending
              ? null
              : (index) => setState(
                  () => _attachments = [..._attachments]..removeAt(index),
                ),
        ),
        AppButton(
          label: l10n.submitComplaint,
          isLoading: isSending,
          onPressed: () => _submit(
            categoryId: categoryId,
            studentId: _studentId(children, about),
          ),
        ),
      ],
    );
  }

  /// The `studentId` of the child at [about]; null for General.
  static int? _studentId(List<ChildEntity> children, int? about) =>
      about == null ? null : children[about].studentId;
}
