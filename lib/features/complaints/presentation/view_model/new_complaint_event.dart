sealed class NewComplaintEvent {
  const NewComplaintEvent();
}

/// Loads the categories (again, after an error or a withdrawn one).
final class LoadComplaintCategoriesEvent extends NewComplaintEvent {
  const LoadComplaintCategoriesEvent();
}

/// Sends the filled-in form.
final class SendComplaintEvent extends NewComplaintEvent {
  const SendComplaintEvent({
    required this.categoryId,
    this.studentId,
    required this.description,
    this.attachments = const [],
  });

  final int categoryId;

  /// Null for a general complaint.
  final int? studentId;
  final String description;

  /// The paths of the files to send with it.
  final List<String> attachments;
}
