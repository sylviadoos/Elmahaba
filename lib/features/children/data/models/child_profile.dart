/// One of the parent's children, as linked through their national ID.
class ChildProfile {
  const ChildProfile({
    required this.fullName,
    required this.grade,
    required this.idTail,
  });

  final String fullName;

  /// e.g. "Grade 4 · 4B"
  final String grade;

  /// Last 4 digits of the national ID.
  final String idTail;

  String get firstName => fullName.split(' ').first;
}
