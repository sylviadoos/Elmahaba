import 'package:al_mahhaba_school/features/complaints/domain/entities/complaints_page_entity.dart';

/// What changes the dot on the Complaints button, sent to
/// `ComplaintUpdatesBloc`.
sealed class ComplaintUpdatesIntent {
  const ComplaintUpdatesIntent();
}

/// Asks the school whether a complaint changed since the parent last
/// looked: at launch, when a notification arrives, and on coming back to
/// the app.
final class LoadComplaintUpdatesIntent extends ComplaintUpdatesIntent {
  const LoadComplaintUpdatesIntent();
}

/// The parent has the complaints on screen, so nothing in them is new any
/// more. [shown] is what they are looking at.
final class ComplaintsSeenIntent extends ComplaintUpdatesIntent {
  const ComplaintsSeenIntent(this.shown);

  final ComplaintsPageEntity shown;
}

/// Takes the dot off, on log out.
final class ClearComplaintUpdatesIntent extends ComplaintUpdatesIntent {
  const ClearComplaintUpdatesIntent();
}
