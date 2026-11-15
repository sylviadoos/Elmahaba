/// Which homework to list.
enum HomeworkFilter {
  all,

  /// Due from today to a week on, the earliest first.
  dueSoon,
  upcoming,
  dueToday,
  past,
  noDueDate,
}
