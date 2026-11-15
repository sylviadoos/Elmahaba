import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_loading.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_attachment_kind.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_file_opener.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_images_viewer.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_file_link.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_file_preview.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_image_grid.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/attachment_picker.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/complaint_labels.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_section.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_details_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_rules_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_status.dart';
import 'package:al_mahhaba_school/features/excuses/domain/excuses_error_codes.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/excuse_image_source.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/extensions/excuse_document_attachment.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/extensions/excuse_labels.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excuse_details_event.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excuse_details_state.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excuse_details_view_model.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/widgets/excuse_documents_field.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/widgets/excuse_history_step.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/widgets/excuse_notice.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/widgets/excuse_status_badge.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';

/// A medical excuse: where it stands, the school's answer, the note and
/// documents, adding documents when the school asks for them, and its
/// history.
class ExcuseDetailsPage extends StatelessWidget {
  const ExcuseDetailsPage({
    super.key,
    required this.childId,
    required this.excuseId,
    this.shown,
    this.rules,
  });

  /// The child's `studentId`.
  final int childId;
  final int excuseId;

  /// The excuse as just sent, shown while it loads.
  final ExcuseDetailsEntity? shown;

  /// The limits for adding documents; the documented ones when null.
  final ExcuseRulesEntity? rules;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExcuseDetailsViewModel>()
        ..doAction(
          ShowExcuseEvent(childId: childId, excuseId: excuseId, shown: shown),
        ),
      child: _ExcuseDetailsView(rules: rules ?? ExcuseRulesEntity.defaults),
    );
  }
}

class _ExcuseDetailsView extends StatefulWidget {
  const _ExcuseDetailsView({required this.rules});

  final ExcuseRulesEntity rules;

  @override
  State<_ExcuseDetailsView> createState() => _ExcuseDetailsViewState();
}

class _ExcuseDetailsViewState extends State<_ExcuseDetailsView> {
  /// Documents picked to add.
  final List<PickedAttachment> _documents = [];

  /// "Send documents" was tapped without one.
  bool _tried = false;

  /// The document tapped, opened once it's downloaded.
  ChatAttachmentEntity? _opening;

  void _open(ChatAttachmentEntity document) {
    _opening = document;
    context.read<ExcuseDetailsViewModel>().doAction(
      DownloadExcuseDocumentEvent(document.asExcuseDocument),
    );
  }

  void _load({bool refresh = false}) => context
      .read<ExcuseDetailsViewModel>()
      .doAction(LoadExcuseEvent(refresh: refresh));

  /// As many as the excuse still has room for, of the kinds the school
  /// takes.
  AttachmentLimits _limits(ExcuseDetailsEntity excuse) {
    final limits = widget.rules.limits;
    return (
      photoExtensions: limits.photoExtensions,
      documentExtensions: limits.documentExtensions,
      maxFiles: math.max(0, excuse.maxDocuments - excuse.documents.length),
      maxMegabytes: limits.maxMegabytes,
    );
  }

  Future<void> _pickDocuments(ExcuseDetailsEntity excuse) async {
    final picked = await context.pickAttachments(
      picked: _documents.length,
      limits: _limits(excuse),
    );
    if (mounted) setState(() => _documents.addAll(picked));
  }

  void _sendDocuments() {
    if (_documents.isEmpty) {
      setState(() => _tried = true);
      return;
    }
    context.read<ExcuseDetailsViewModel>().doAction(
      AddExcuseDocumentsEvent([for (final file in _documents) file.path]),
    );
  }

  void _onAdding(BuildContext context, ExcuseDetailsState state) {
    final adding = state.adding;
    if (adding.state == StateType.success) {
      setState(() {
        _documents.clear();
        _tried = false;
      });
      context.showSnackBar(context.l10n.documentsSent);
    }
    final exception = adding.exception;
    if (adding.state != StateType.error || exception == null) return;
    context.showSnackBar(exception.localizedMessage(context), isError: true);
    if (exception is UnauthorizedException) {
      context.logOut();
    } else if (exception case ServerException(
      code: ExcusesErrorCodes.notAwaitingDocuments,
    )) {
      // The school moved on meanwhile: show where it stands now.
      _load(refresh: true);
    }
  }

  Future<void> _onDownload(
    BuildContext context,
    ExcuseDetailsState state,
  ) async {
    final download = state.download;
    if (download.state == StateType.error) {
      context.showSnackBar(
        download.exception!.localizedMessage(context),
        isError: true,
      );
      return;
    }
    final opening = _opening;
    if (download.state != StateType.success || opening == null) return;
    // A PDF full screen here, like a photo; anything else in its app.
    await context.openChatFile(download.data!, opening);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return MultiBlocListener(
      listeners: [
        // Signed out meanwhile: back to Log in.
        BlocListener<ExcuseDetailsViewModel, ExcuseDetailsState>(
          listenWhen: (previous, current) =>
              previous.details.state != current.details.state &&
              current.details.exception is UnauthorizedException,
          listener: (context, state) {
            context.showSnackBar(
              state.details.exception!.localizedMessage(context),
              isError: true,
            );
            context.logOut();
          },
        ),
        BlocListener<ExcuseDetailsViewModel, ExcuseDetailsState>(
          listenWhen: (previous, current) =>
              previous.adding.state != current.adding.state,
          listener: _onAdding,
        ),
        BlocListener<ExcuseDetailsViewModel, ExcuseDetailsState>(
          listenWhen: (previous, current) =>
              previous.download.state != current.download.state,
          listener: _onDownload,
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: BlocBuilder<ExcuseDetailsViewModel, ExcuseDetailsState>(
            builder: (context, state) {
              final excuse = state.details.data;
              final date = excuse?.absenceDate;

              return Column(
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
                        const AppBackButton(
                          fallbackRoute: AppRoutes.attendance,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.medicalExcuse,
                                style: textTheme.headlineMedium?.copyWith(
                                  fontSize: 24.sp,
                                  height: 1.25,
                                  letterSpacing: 0,
                                  color: AppColors.white,
                                ),
                              ),
                              if (date != null)
                                Text(
                                  l10n.excuseForAbsence(
                                    date.excuseDayLabel(context),
                                  ),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.white.withValues(
                                      alpha: 0.88,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: excuse == null
                        ? _loadingOrError(context, state)
                        : RefreshIndicator(
                            color: AppColors.mahabbahRed,
                            onRefresh: () async => _load(refresh: true),
                            child: _content(context, state, excuse),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _loadingOrError(BuildContext context, ExcuseDetailsState state) {
    final exception = state.details.exception;
    if (exception == null) return const AppLoading();
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: StateMessage(
        icon: AppIcons.navAttendance,
        title: exception.localizedMessage(context),
        action: RetryOrLogInButton(exception: exception, onRetry: _load),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    ExcuseDetailsState state,
    ExcuseDetailsEntity excuse,
  ) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final submittedAt = excuse.submittedAt;
    final rejectionReason = excuse.rejectionReason;
    final informationRequest = excuse.informationRequest;
    final note = excuse.note;
    final isAdding = state.adding.state == StateType.loading;
    final limits = _limits(excuse);
    // Shown as the chat shows its files.
    final documents = [
      for (final document in excuse.documents) document.asAttachment,
    ];
    final photos = [
      for (final document in documents)
        if (document.isImage) document,
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20.w,
        4.h,
        20.w,
        math.max(40.h, MediaQuery.paddingOf(context).bottom + 16),
      ),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16.h,
          children: [
            Row(
              spacing: 10.w,
              children: [
                ExcuseStatusBadge(excuse.status),
                if (submittedAt != null)
                  Expanded(
                    child: Text(
                      l10n.submittedOn(submittedAt.dateTimeLabel(context)),
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.slate,
                      ),
                    ),
                  ),
              ],
            ),
            if (!excuse.submittedByYou)
              Text(
                l10n.excuseSubmittedByOther,
                style: textTheme.bodySmall?.copyWith(color: AppColors.slate),
              ),
            if (excuse.status == ExcuseStatus.rejected &&
                rejectionReason != null)
              ExcuseNotice(
                title: l10n.excuseRejectionReason,
                text: rejectionReason,
                foreground: AppColors.error,
                background: AppColors.errorBg,
              ),
            if (informationRequest != null &&
                excuse.status == ExcuseStatus.infoRequired)
              ExcuseNotice(
                title: l10n.excuseInformationRequest,
                text: informationRequest,
                foreground: AppColors.warning,
                background: AppColors.warningBg,
              ),
            if (excuse.status == ExcuseStatus.accepted)
              ExcuseNotice(
                text: l10n.excuseAcceptedNote,
                foreground: AppColors.success,
                background: AppColors.successBg,
              ),
            if (note != null)
              ComplaintSection(
                title: l10n.excuseNote,
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Text(
                    note,
                    textDirection: note.textDirection,
                    style: textTheme.bodyMedium,
                  ),
                ),
              ),
            ComplaintSection(
              title: l10n.excuseDocuments,
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8.h,
                  children: [
                    // Photos show, opened full screen by a tap.
                    if (photos.isNotEmpty)
                      LayoutBuilder(
                        builder: (_, constraints) => ChatImageGrid(
                          source: const ExcuseImageSource(),
                          images: photos,
                          width: constraints.maxWidth,
                        ),
                      ),
                    // The other files: a PDF with its first page on top.
                    for (final document in documents)
                      if (!document.isImage)
                        ChatFileLink(
                          attachment: document,
                          isDownloading: state.downloadingId == document.id,
                          onOpen: state.downloadingId == null
                              ? () => _open(document)
                              : null,
                          preview: document.isPdf
                              ? ChatFilePreview(
                                  source: const ExcuseImageSource(),
                                  attachment: document,
                                )
                              : null,
                        ),
                    // The school asked for more.
                    if (excuse.canAddDocuments && limits.maxFiles > 0) ...[
                      SizedBox(height: 8.h),
                      ExcuseDocumentsField(
                        label: l10n.addDocuments,
                        files: _documents,
                        limits: limits,
                        onAdd: isAdding ? null : () => _pickDocuments(excuse),
                        onRemove: isAdding
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
                        label: l10n.sendDocuments,
                        isLoading: isAdding,
                        onPressed: _sendDocuments,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (excuse.history.isNotEmpty)
              ComplaintSection(
                title: l10n.excuseHistory,
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (index, step) in excuse.history.indexed)
                        ExcuseHistoryStep(
                          step: step,
                          last: index == excuse.history.length - 1,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
