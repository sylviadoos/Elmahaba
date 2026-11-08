/// Where a homework stands against its due date, by the school's day.
enum HomeworkDueStatus {
  upcoming,
  dueToday,

  /// Its due date has passed.
  past,

  /// The school gave it none.
  noDueDate,

  /// A status the app doesn't know yet.
  unknown,
}
