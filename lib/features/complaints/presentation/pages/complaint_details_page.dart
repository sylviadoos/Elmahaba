import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';
import 'package:al_mahhaba_school/features/complaints/domain/complaints_error_codes.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_attachment_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_details_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/attachment_picker.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/complaint_labels.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/complaint_details_event.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/complaint_details_state.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/complaint_details_view_model.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_closed_box.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_details_skeleton.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_fact_row.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_file_link.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_reply_box.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_section.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_status_badge.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_status_step.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_update.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/settings_button.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';

/// One complaint: its details, what was sent, how its status changed, the
/// school's updates, and a reply when the school asks for one.
class ComplaintDetailsPage extends StatelessWidget {
  const ComplaintDetailsPage({
    super.key,
    required this.complaintId,
    this.preview,
  });

  final int complaintId;

  /// The complaint as the page before showed it, for the header while the
  /// rest loads.
  final ComplaintEntity? preview;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ComplaintDetailsViewModel>()
            ..doAction(LoadComplaintDetailsEvent(complaintId)),
      child: _ComplaintDetailsView(complaintId: complaintId, preview: preview),
    );
  }
}

class _ComplaintDetailsView extends StatefulWidget {
  const _ComplaintDetailsView({required this.complaintId, this.preview});

  final int complaintId;
  final ComplaintEntity? preview;

  @override
  State<_ComplaintDetailsView> createState() => _ComplaintDetailsViewState();
}

class _ComplaintDetailsViewState extends State<_ComplaintDetailsView> {
  final TextEditingController _reply = TextEditingController();

  /// With the ones that won't be sent, which say why.
  List<PickedAttachment> _attachments = [];

  /// The reply has text (files alone make a reply too).
  bool _hasText = false;

  /// Why the last reply wasn't sent.
  String? _replyError;

  /// The last reply went through; said until the next one is started.
  bool _replySent = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  void _load({bool refresh = false}) =>
      context.read<ComplaintDetailsViewModel>().doAction(
        LoadComplaintDetailsEvent(widget.complaintId, refresh: refresh),
      );

  Future<void> _pickAttachments() async {
    final picked = await context.pickComplaintAttachments(
      current: _attachments,
    );
    if (!mounted || picked.isEmpty) return;
    _startReply();
    setState(() => _attachments = [..._attachments, ...picked]);
  }

  /// A new reply: the notes about the last one go.
  void _startReply() {
    if (_replyError == null && !_replySent) return;
    setState(() {
      _replyError = null;
      _replySent = false;
    });
  }

  void _onReplyChanged(String text) {
    _startReply();
    final hasText = text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  /// Text, or a file that can go (files alone make a reply), and no file
  /// picked only to be refused.
  bool get _canSend =>
      !_attachments.allInvalid && (_hasText || _attachments.valid.isNotEmpty);

  void _send() {
    if (!_canSend) return;
    _startReply();
    FocusScope.of(context).unfocus();
    context.read<ComplaintDetailsViewModel>().doAction(
      SendComplaintReplyEvent(
        text: _reply.text.trim(),
        // The ones that can't go stay on screen, saying why.
        attachments: [for (final file in _attachments.valid) file.path],
      ),
    );
  }

  void _onReplied(ComplaintDetailsState state) {
    _reply.clear();
    setState(() {
      _attachments = [];
      _hasText = false;
      _replySent = true;
    });
    // The school has the answer, so the reply box usually goes, and its
    // note with it.
    if (state.details.data?.complaint.canReply != true) {
      context.showSnackBar(context.l10n.replySent);
    }
  }

  void _onReplyError(AppException exception) {
    if (exception is UnauthorizedException) {
      context.showSnackBar(exception.localizedMessage(context), isError: true);
      context.logOut();
      return;
    }
    if (exception case ServerException(
      code: ComplaintsErrorCodes.complaintClosed ||
          ComplaintsErrorCodes.complaintReplyNotAllowed,
    )) {
      // It changed meanwhile: shown as it is now, without the reply box
      // (and its note), so the reason goes in a snack bar.
      context.showSnackBar(exception.localizedMessage(context), isError: true);
      _load(refresh: true);
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
    setState(
      () => _replyError =
          fieldErrors.values.firstOrNull ?? exception.localizedMessage(context),
    );
  }

  void _openAttachment(ComplaintAttachmentEntity attachment) => context
      .read<ComplaintDetailsViewModel>()
      .doAction(DownloadAttachmentEvent(attachment));

  Future<void> _open(String path) async {
    final result = await OpenFilex.open(path);
    if (!mounted || result.type == ResultType.done) return;
    context.showSnackBar(context.l10n.cantOpenFile, isError: true);
  }

  void _listenReply(BuildContext context, ComplaintDetailsState state) {
    final reply = state.reply;
    if (reply.state == StateType.success) _onReplied(state);
    if (reply.state == StateType.error) _onReplyError(reply.exception!);
  }

  void _listenDownload(BuildContext context, ComplaintDetailsState state) {
    final download = state.download;
    if (download.state == StateType.success) _open(download.data!);
    if (download.state == StateType.error) {
      context.showSnackBar(
        download.exception!.localizedMessage(context),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ComplaintDetailsViewModel, ComplaintDetailsState>(
          listenWhen: (previous, current) =>
              previous.reply.state != current.reply.state,
          listener: _listenReply,
        ),
        BlocListener<ComplaintDetailsViewModel, ComplaintDetailsState>(
          listenWhen: (previous, current) =>
              previous.download.state != current.download.state,
          listener: _listenDownload,
        ),
      ],
      child: BlocBuilder<ComplaintDetailsViewModel, ComplaintDetailsState>(
        builder: (context, state) {
          final details = state.details.data;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(context, details?.complaint ?? widget.preview),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        20.w,
                        4.h,
                        20.w,
                        math.max(
                          40.h,
                          MediaQuery.paddingOf(context).bottom + 16,
                        ),
                      ),
                      child: details == null
                          ? _loadingOrError(context, state)
                          : _content(context, state, details),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, ComplaintEntity? complaint) {
    final textTheme = context.textTheme;

    return RedHeader(
      horizontalPadding: 16,
      bottomPadding: 40,
      watermarkTop: 20,
      watermarkSize: const Size(200, 143),
      child: Row(
        spacing: 10.w,
        children: [
          const AppBackButton(fallbackRoute: AppRoutes.complaints),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.complaint,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    height: 16 / 12,
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    complaint?.referenceLabel ?? '',
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 20.sp,
                      height: 26 / 20,
                      letterSpacing: 0,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (complaint != null)
            ComplaintStatusBadge(complaint.status, onRed: true),
          const SettingsButton(),
        ],
      ),
    );
  }

  /// Loading the complaint, or why it didn't load.
  Widget _loadingOrError(BuildContext context, ComplaintDetailsState state) {
    final exception = state.details.exception;

    return exception == null
        ? const ComplaintDetailsSkeleton()
        : StateMessage(
            icon: AppIcons.complaint,
            title: exception.localizedMessage(context),
            action: RetryOrLogInButton(exception: exception, onRetry: _load),
          );
  }

  Widget _content(
    BuildContext context,
    ComplaintDetailsState state,
    ComplaintDetailsEntity details,
  ) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final complaint = details.complaint;
    final facts = [
      (l10n.complaintCategory, complaint.categoryName(context)),
      (l10n.complaintAbout, complaint.aboutLabel(context)),
      if (complaint.submittedAt case final at?)
        (l10n.submittedAt, at.dateTimeLabel(context)),
      if (complaint.lastUpdate case final at?)
        (l10n.lastUpdate, at.dateTimeLabel(context)),
    ];
    final description = details.description;
    final history = details.statusHistory.reversed.toList();
    final updates = details.updates;
    final isReplying = state.reply.state == StateType.loading;

    Widget fileLink(ComplaintAttachmentEntity attachment) => ComplaintFileLink(
      attachment: attachment,
      isDownloading: attachment.id == state.downloadingId,
      onOpen: state.downloadingId == null
          ? () => _openAttachment(attachment)
          : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16.h,
      children: [
        ComplaintSection(
          title: l10n.complaintDetails,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
            child: Column(
              children: [
                for (final (index, (label, value)) in facts.indexed)
                  ComplaintFactRow(
                    label: label,
                    value: value,
                    last: index == facts.length - 1,
                  ),
              ],
            ),
          ),
        ),
        ComplaintSection(
          title: l10n.yourComplaint,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10.h,
              children: [
                if (description.isNotEmpty)
                  Text(
                    description,
                    // In the language it was written in, on the page's side.
                    textDirection: description.textDirection,
                    textAlign: Directionality.of(context) == TextDirection.rtl
                        ? TextAlign.right
                        : TextAlign.left,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 15.sp,
                      height: 23 / 15,
                    ),
                  ),
                for (final attachment in details.opening?.attachments ?? [])
                  fileLink(attachment),
              ],
            ),
          ),
        ),
        if (history.isNotEmpty)
          ComplaintSection(
            title: l10n.statusHistory,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                children: [
                  for (final (index, change) in history.indexed)
                    ComplaintStatusStep(
                      change: change,
                      latest: index == 0,
                      last: index == history.length - 1,
                    ),
                ],
              ),
            ),
          ),
        if (updates.isNotEmpty)
          ComplaintSection(
            title: l10n.complaintUpdates,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, message) in updates.indexed)
                  ComplaintUpdate(
                    message: message,
                    first: index == 0,
                    downloadingId: state.downloadingId,
                    onOpenAttachment: _openAttachment,
                  ),
              ],
            ),
          ),
        // Only while the school awaits the parent's answer; nothing while
        // it's on the complaint.
        if (complaint.canReply)
          ComplaintReplyBox(
            controller: _reply,
            attachments: _attachments,
            upload: isReplying
                ? state.upload ?? (sent: 0, total: _attachments.validBytes)
                : null,
            isSending: isReplying,
            sent: _replySent,
            errorText: _replyError,
            onChanged: _onReplyChanged,
            onAttach: _attachments.canAddMore ? _pickAttachments : null,
            onRemoveAttachment: (index) => setState(
              () => _attachments = [..._attachments]..removeAt(index),
            ),
            onSend: _canSend ? _send : null,
          )
        else if (!complaint.isOpen)
          ComplaintClosedBox(
            // In this page's place, so going back from it leads to
            // Complaints.
            onNewComplaint: () =>
                context.pushReplacement(AppRoutes.newComplaint),
          ),
      ],
    );
  }
}
