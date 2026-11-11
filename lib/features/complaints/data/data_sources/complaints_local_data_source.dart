/// How far the parent has read their complaints, kept on this phone. The
/// API has no unread count for complaints, so the dot on the Complaints
/// button comes from comparing this with what the school sends.
abstract interface class ComplaintsLocalDataSource {
  /// The newest complaint change the parent has seen; null when they
  /// haven't opened their complaints on this phone yet.
  DateTime? getSeenUpdate();

  Future<void> saveSeenUpdate(DateTime updatedAt);

  /// The changes the parent made themselves (a complaint sent, a reply),
  /// by complaint id: when each was changed by them. Not news to them, so
  /// no dot for these.
  Map<int, DateTime> getOwnUpdates();

  Future<void> saveOwnUpdates(Map<int, DateTime> updates);

  /// Forgets both (log out): the next parent's complaints aren't this one's.
  Future<void> clearSeenUpdate();
}
