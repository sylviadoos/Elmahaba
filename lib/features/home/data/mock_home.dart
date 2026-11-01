/// Where a "Needs your attention" item leads.
enum AttentionLink { chat, fees }

class AttentionItem {
  const AttentionItem(this.text, this.link);

  final String text;
  final AttentionLink link;
}

/// Home summary for one child.
class ChildDashboard {
  const ChildDashboard({
    required this.absentToday,
    required this.todayStatus,
    required this.average,
    required this.averageNote,
    required this.presentDays,
    required this.attendanceNote,
    required this.feesPaid,
    required this.feesNote,
    required this.unread,
    required this.lastMessage,
    required this.attention,
  });

  final bool absentToday;
  final String todayStatus;

  /// Term average, 0–1.
  final double average;
  final String averageNote;
  final String presentDays;
  final String attendanceNote;

  /// Share of the year's fees paid, 0–1.
  final double feesPaid;
  final String feesNote;
  final int unread;
  final String lastMessage;
  final List<AttentionItem> attention;
}

// TODO: replace with the dashboard API. Mock content from the design, in
// the same order as mockChildren.
final DateTime mockToday = DateTime(2026, 10, 26);
const int mockNotificationCount = 4;

const List<ChildDashboard> mockDashboards = [
  ChildDashboard(
    absentToday: true,
    todayStatus: 'Absent · you replied: sick',
    average: 0.92,
    averageNote: 'Term 1 · Excellent',
    presentDays: '15/17',
    attendanceNote: '1 absent · 1 late',
    feesPaid: 0.5,
    feesNote: 'EGP 20,000 due Nov 7',
    unread: 2,
    lastMessage: 'Please bring the Science book tomorrow',
    attention: [
      AttentionItem(
        'Reply: bring the Science book tomorrow',
        AttentionLink.chat,
      ),
      AttentionItem('Pay Term 2 fees by Nov 7', AttentionLink.fees),
    ],
  ),
  ChildDashboard(
    absentToday: false,
    todayStatus: 'Present · arrived 7:50',
    average: 0.96,
    averageNote: 'Term 1 · Excellent',
    presentDays: '16/17',
    attendanceNote: '0 absent · 1 late',
    feesPaid: 1,
    feesNote: 'All fees paid',
    unread: 3,
    lastMessage: 'Please send a family photo by Thursday',
    attention: [
      AttentionItem('Send a family photo by Thursday', AttentionLink.chat),
    ],
  ),
];
