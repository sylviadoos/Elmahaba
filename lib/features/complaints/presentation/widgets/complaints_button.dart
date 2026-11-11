import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/header_icon_button.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/bloc/complaint_updates_bloc.dart';

/// Opens the parent's complaints, from the red header of a parent page,
/// with a dot while the school has replied to one or changed its status.
class ComplaintsButton extends StatelessWidget {
  const ComplaintsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HeaderIconButton(
      icon: AppIcons.complaint,
      tooltip: context.l10n.complaints,
      showDot: context.watch<ComplaintUpdatesBloc>().state,
      onPressed: () => context.push(AppRoutes.complaints),
    );
  }
}
