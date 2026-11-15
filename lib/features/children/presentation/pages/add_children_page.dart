import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/scrollable_fill.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_request_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_result_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/add_children_header.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/national_id_field.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/your_children_section.dart';

/// Link children by their national ID; lists the ones on the account.
///
/// Uses the app's shared [ChildrenViewModel], so a linked child shows up in
/// every header too.
class AddChildrenPage extends StatefulWidget {
  const AddChildrenPage({super.key});

  @override
  State<AddChildrenPage> createState() => _AddChildrenPageState();
}

class _AddChildrenPageState extends State<AddChildrenPage> {
  final TextEditingController _idController = TextEditingController();

  /// The server's error for the ID, shown until it's edited.
  String? _idError;

  @override
  void initState() {
    super.initState();
    // The saved list shows at once; the API brings it up to date.
    context.read<ChildrenViewModel>().doAction(const LoadChildrenEvent());
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _addChild() {
    FocusScope.of(context).unfocus();
    context.read<ChildrenViewModel>().doAction(
      LinkChildEvent(LinkChildRequestEntity(nationalId: _idController.text)),
    );
  }

  void _onLinked(BuildContext context, ChildrenState state) {
    final l10n = context.l10n;
    final link = state.link;

    if (link.data case final result?) {
      final done = switch (result) {
        ChildLinked() => l10n.childLinked,
        ChildLinkPending() => l10n.childLinkPending,
        // The school texted a code to the child's own phone: entered on its
        // page, which links the child — then this one says so. The ID
        // stays meanwhile, to try again from.
        ChildLinkCodeSent() => null,
      };
      if (done == null) {
        context.push(
          AppRoutes.linkChildCode,
          extra: (result as ChildLinkCodeSent).verification,
        );
        return;
      }
      // In setState: Continue waits on the field being empty again.
      setState(() {
        _idController.clear();
        _idError = null;
      });
      context.showSnackBar(done);
      return;
    }

    final exception = link.exception!;
    final idError = exception is ServerException
        ? exception.fieldErrors['national_id']
        : null;
    setState(() => _idError = idError);
    // child_already_linked, not found… come with the server's message.
    context.showSnackBar(
      idError ?? exception.localizedMessage(context),
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.mahabbahRed,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AddChildrenHeader(),
            Expanded(
              child: ColoredBox(
                color: AppColors.white,
                child: ScrollableFill(
                  padding: EdgeInsets.fromLTRB(
                    24.w,
                    24.h,
                    24.w,
                    math.max(32.h, bottomInset + 16),
                  ),
                  child: BlocConsumer<ChildrenViewModel, ChildrenState>(
                    listenWhen: (previous, current) =>
                        previous.link != current.link &&
                        (current.link.state == StateType.success ||
                            current.link.state == StateType.error),
                    listener: _onLinked,
                    builder: (context, state) {
                      final children = state.children.data;
                      // An ID typed but not added yet: Continue would
                      // leave the page and drop it, so it waits for Add.
                      final idWaiting = _idController.text.isNotEmpty;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 16.h,
                        children: [
                          NationalIdField(
                            controller: _idController,
                            isLinking: state.link.state == StateType.loading,
                            errorText: _idError,
                            // Also updates the counter and the Add button.
                            onChanged: (_) => setState(() => _idError = null),
                            onAdd: _addChild,
                          ),
                          YourChildrenSection(
                            children: state.children,
                            onRetry: () => context
                                .read<ChildrenViewModel>()
                                .doAction(const LoadChildrenEvent()),
                          ),
                          const Spacer(),
                          AppButton(
                            label: context.l10n.continueButton,
                            onPressed:
                                children == null ||
                                    children.isEmpty ||
                                    idWaiting
                                ? null
                                : () => context.go(AppRoutes.home),
                            trailingIcon: AppSvgIcon(
                              AppIcons.arrowRight,
                              size: 20.r,
                              matchTextDirection: true,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
