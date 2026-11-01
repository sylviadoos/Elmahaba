enum NotificationGroup { today, yesterday, earlier }

enum NotificationType { chat, results, attendance, fees, holiday }

class AppNotification {
  const AppNotification({
    required this.group,
    required this.childIndex,
    required this.type,
    required this.time,
    required this.title,
    required this.detail,
    this.isUnread = false,
  });

  final NotificationGroup group;

  /// Index in mockChildren, or null when it's for all parents.
  final int? childIndex;
  final NotificationType type;
  final String time;
  final String title;
  final String detail;
  final bool isUnread;
}

// TODO: replace with the notifications API. Mock content from the design.
const List<AppNotification> mockNotifications = [
  AppNotification(
    group: NotificationGroup.today,
    childIndex: null,
    type: NotificationType.chat,
    time: '9:41',
    title: 'Birthday celebration',
    detail: 'A general message for all parents',
    isUnread: true,
  ),
  AppNotification(
    group: NotificationGroup.today,
    childIndex: 0,
    type: NotificationType.chat,
    time: '9:30',
    title: 'Please bring the Science book tomorrow',
    detail: 'Class 4B · tap to reply',
    isUnread: true,
  ),
  AppNotification(
    group: NotificationGroup.today,
    childIndex: 1,
    type: NotificationType.chat,
    time: '9:20',
    title: 'Please send a family photo by Thursday',
    detail: 'KG 2 · general message',
    isUnread: true,
  ),
  AppNotification(
    group: NotificationGroup.today,
    childIndex: 0,
    type: NotificationType.results,
    time: '9:10',
    title: 'Term 1 results are out',
    detail: 'Average 92% · Excellent',
    isUnread: true,
  ),
  AppNotification(
    group: NotificationGroup.today,
    childIndex: 1,
    type: NotificationType.results,
    time: '9:05',
    title: 'Term 1 report is ready',
    detail: 'Average 96% · Excellent',
  ),
  AppNotification(
    group: NotificationGroup.today,
    childIndex: 0,
    type: NotificationType.attendance,
    time: '8:05',
    title: 'Omar was absent today',
    detail: 'You replied: sick',
  ),
  AppNotification(
    group: NotificationGroup.yesterday,
    childIndex: 0,
    type: NotificationType.fees,
    time: '6:00 PM',
    title: 'Term 2 fees due in 12 days',
    detail: 'EGP 20,000 · due Nov 7',
  ),
  AppNotification(
    group: NotificationGroup.earlier,
    childIndex: 0,
    type: NotificationType.attendance,
    time: 'Oct 14',
    title: 'Omar arrived late',
    detail: 'Arrived at 8:20',
  ),
  AppNotification(
    group: NotificationGroup.earlier,
    childIndex: null,
    type: NotificationType.holiday,
    time: 'Oct 5',
    title: 'Tomorrow is an official holiday',
    detail: 'Armed Forces Day · no school on Oct 6',
  ),
  AppNotification(
    group: NotificationGroup.earlier,
    childIndex: 1,
    type: NotificationType.fees,
    time: 'Oct 2',
    title: 'Payment received',
    detail: 'Term 2 tuition · receipt saved',
  ),
];
