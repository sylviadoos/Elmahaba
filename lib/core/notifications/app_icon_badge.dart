/// The number on the app's icon, outside the app: what's new for the
/// parent, so they see it without opening the app.
abstract class AppIconBadge {
  /// Shows [count] on the icon; 0 takes the number off. Does nothing where
  /// the phone's launcher has no number on its icons.
  Future<void> show(int count);
}
