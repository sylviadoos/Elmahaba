import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_page_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_subject_entity.dart';

/// Everything Homework shows: whose, which, and the homework loaded.
class HomeworkState extends Equatable {
  const HomeworkState({
    this.children = const [],
    this.isRequested = false,
    this.studentId,
    this.filter = HomeworkFilter.all,
    this.subjectId,
    this.homework = const BaseState.initial(),
    this.subjects = const [],
    this.downloadingId,
  });

  /// The parent's children.
  final List<ChildEntity> children;

  /// Whether homework was asked for yet (the children may still be loading).
  final bool isRequested;

  /// The child whose homework is shown; null while there's none.
  final int? studentId;
  final HomeworkFilter filter;

  /// The subject it's limited to; null for all of them.
  final int? subjectId;

  /// The pages loaded. `moreLoading` while the next loads; an error with
  /// data when it didn't. Loading with data while it loads again (pulled
  /// down).
  final BaseState<HomeworkPageEntity> homework;

  /// The child's subjects, to filter by. Kept while a subject is picked.
  final List<HomeworkSubjectEntity> subjects;

  /// The file downloading now.
  final int? downloadingId;

  HomeworkPageEntity? get page => homework.data;

  /// Where the child shown is in [children]; -1 for none.
  int get shownIndex =>
      children.indexWhere((child) => child.studentId == studentId);

  /// Only some of the homework is asked for.
  bool get isFiltered => filter != HomeworkFilter.all || subjectId != null;

  HomeworkState copyWith({
    List<ChildEntity>? children,
    bool? isRequested,
    int? Function()? studentId,
    HomeworkFilter? filter,
    int? Function()? subjectId,
    BaseState<HomeworkPageEntity>? homework,
    List<HomeworkSubjectEntity>? subjects,
    int? Function()? downloadingId,
  }) => HomeworkState(
    children: children ?? this.children,
    isRequested: isRequested ?? this.isRequested,
    studentId: studentId != null ? studentId() : this.studentId,
    filter: filter ?? this.filter,
    subjectId: subjectId != null ? subjectId() : this.subjectId,
    homework: homework ?? this.homework,
    subjects: subjects ?? this.subjects,
    downloadingId: downloadingId != null ? downloadingId() : this.downloadingId,
  );

  @override
  List<Object?> get props => [
    children,
    isRequested,
    studentId,
    filter,
    subjectId,
    homework,
    subjects,
    downloadingId,
  ];
}
