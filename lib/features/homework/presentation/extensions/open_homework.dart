import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/presentation/homework_args.dart';

extension OpenHomework on BuildContext {
  /// Opens [homework] on a page of its own, over what the parent was
  /// looking at. It goes with it: the school isn't asked for it again.
  void openHomework(HomeworkEntity homework, {int? studentId}) => push(
    AppRoutes.homeworkDetailsOf(homework.id),
    extra: HomeworkArgs(homework: homework, studentId: studentId),
  );
}
