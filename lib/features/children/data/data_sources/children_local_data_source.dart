import 'package:al_mahhaba_school/features/children/data/models/child_model.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';

/// The parent's children kept on the phone, so the headers show them
/// without calling the API each time.
abstract interface class ChildrenLocalDataSource {
  /// The saved children; empty when none are saved (or can't be read).
  Future<List<ChildModel>> getSavedChildren();

  Future<void> saveChildren(List<ChildEntity> children);

  /// The child last picked to show on every page, by `studentId`; null
  /// when none was (or it can't be read).
  Future<int?> getSelectedChildId();

  Future<void> saveSelectedChildId(int studentId);

  /// Forgets them and the one picked (log out), so the next parent
  /// doesn't see them.
  Future<void> clearChildren();
}
