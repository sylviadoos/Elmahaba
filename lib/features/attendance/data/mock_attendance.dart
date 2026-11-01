enum DayStatus { present, absent, late, holiday, off, future }

enum AttendanceEventType { absent, late, holiday }

class AttendanceEvent {
  const AttendanceEvent(this.day, this.type, this.detail);

  final int day;
  final AttendanceEventType type;
  final String detail;
}

class MonthAttendance {
  const MonthAttendance({
    required this.absentDays,
    required this.lateDays,
    required this.events,
  });

  final Set<int> absentDays;
  final Set<int> lateDays;
  final List<AttendanceEvent> events;
}

// TODO: replace with the attendance API. Mock content from the design
// (October 2026), in the same order as mockChildren.
final DateTime mockAttendanceMonth = DateTime(2026, 10);
const int mockAttendanceToday = 26;

/// Oct 6 — Armed Forces Day.
const Set<int> mockHolidays = {6};

const List<MonthAttendance> mockAttendance = [
  MonthAttendance(
    absentDays: {26},
    lateDays: {14},
    events: [
      AttendanceEvent(
        26,
        AttendanceEventType.absent,
        'Reason: sick (replied in chat)',
      ),
      AttendanceEvent(14, AttendanceEventType.late, 'Arrived at 8:20'),
      AttendanceEvent(
        6,
        AttendanceEventType.holiday,
        'Armed Forces Day · no school',
      ),
    ],
  ),
  MonthAttendance(
    absentDays: {},
    lateDays: {7},
    events: [
      AttendanceEvent(7, AttendanceEventType.late, 'Arrived at 8:15'),
      AttendanceEvent(
        6,
        AttendanceEventType.holiday,
        'Armed Forces Day · no school',
      ),
    ],
  ),
];

/// Status of [day] in [month] for one child. Fridays and Saturdays are the
/// weekend in Egypt.
DayStatus dayStatus(DateTime month, int day, MonthAttendance attendance) {
  final weekday = DateTime(month.year, month.month, day).weekday;
  if (weekday == DateTime.friday || weekday == DateTime.saturday) {
    return DayStatus.off;
  }
  if (mockHolidays.contains(day)) return DayStatus.holiday;
  if (day > mockAttendanceToday) return DayStatus.future;
  if (attendance.absentDays.contains(day)) return DayStatus.absent;
  if (attendance.lateDays.contains(day)) return DayStatus.late;
  return DayStatus.present;
}
