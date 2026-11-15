import 'package:equatable/equatable.dart';

/// The newest few of something for a child (announcements, homework,
/// results), newest first.
class LatestItemsEntity<T> extends Equatable {
  const LatestItemsEntity({
    this.items = const [],
    this.total = 0,
    this.unread = 0,
  });

  final List<T> items;

  /// How many there are in all.
  final int total;

  /// How many the parent hasn't seen.
  final int unread;

  @override
  List<Object?> get props => [items, total, unread];
}
