class SubjectResult {
  const SubjectResult(this.short, this.name, this.score, this.maxScore);

  /// Two-letter label shown in the tile, e.g. "Ma".
  final String short;
  final String name;
  final int score;
  final int maxScore;

  double get fraction => score / maxScore;
}

class TermResults {
  const TermResults({
    required this.average,
    required this.level,
    required this.teacherNote,
    required this.subjects,
  });

  /// 0–1
  final double average;
  final String level;
  final String teacherNote;
  final List<SubjectResult> subjects;
}

// TODO: replace with the results API. Mock content from the design, in the
// same order as mockChildren.
const List<TermResults> mockTerm1Results = [
  TermResults(
    average: 0.92,
    level: 'Excellent',
    teacherNote:
        'Omar is hard-working and participates well in class. Keep practising reading at home.',
    subjects: [
      SubjectResult('Ar', 'Arabic', 18, 20),
      SubjectResult('En', 'English', 19, 20),
      SubjectResult('Ma', 'Math', 19, 20),
      SubjectResult('Sc', 'Science', 17, 20),
      SubjectResult('So', 'Social Studies', 18, 20),
      SubjectResult('Re', 'Religion', 20, 20),
    ],
  ),
  TermResults(
    average: 0.96,
    level: 'Excellent',
    teacherNote:
        'Lina is cheerful and curious. She knows all her letters and loves story time.',
    subjects: [
      SubjectResult('Ar', 'Arabic', 10, 10),
      SubjectResult('En', 'English', 9, 10),
      SubjectResult('Ma', 'Math', 10, 10),
      SubjectResult('Sk', 'Life skills', 9, 10),
    ],
  ),
];
