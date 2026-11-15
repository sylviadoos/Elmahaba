import 'package:al_mahhaba_school/features/excuses/domain/entities/new_excuse_entity.dart';

sealed class NewExcuseEvent {
  const NewExcuseEvent();
}

/// Sends [excuse] for the child with [childId] (`studentId`).
final class SubmitExcuseEvent extends NewExcuseEvent {
  const SubmitExcuseEvent({required this.childId, required this.excuse});

  final int childId;
  final NewExcuseEntity excuse;
}
