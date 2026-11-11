import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/fees/domain/entities/installment_status.dart';
import 'package:al_mahhaba_school/features/home/data/models/child_dashboard_model.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_due_status.dart';

import '../../home_fixtures.dart';

void main() {
  test('reads all of the API\'s example', () {
    final dashboard = ChildDashboardModel.fromJson(dashboardJson);

    expect(dashboard.child?.studentId, 9);
    expect(dashboard.child?.grade, 'Second Primary');

    final attendance = dashboard.attendance;
    expect(attendance.todayStatus, 'absent');
    expect(attendance.allowedAbsenceDays, 4);
    expect(attendance.actualAbsenceDays, 1);
    expect(attendance.remainingAbsenceDays, 3);
    expect(attendance.exceededAbsenceDays, 0);

    final announcements = dashboard.announcements;
    expect(announcements.total, 3);
    expect(announcements.unread, 0);
    expect(announcements.items.map((each) => each.id), [3, 2]);
    expect(announcements.items.last.isEdited, isTrue);
    expect(announcements.items.last.chatKey, 'event:38');

    final homework = dashboard.homework.items.single;
    expect(homework.title, 'teest');
    expect(homework.subject, 'Arabic');
    expect(homework.dueStatus, HomeworkDueStatus.upcoming);
    expect(homework.attachments.single.fileName, 'SRS_IEEE830 (1).pdf');

    expect(dashboard.latestResult?.id, 280);
    expect(dashboard.results.total, 7);
    expect(dashboard.results.items.map((each) => each.id), [280, 222]);
    expect(dashboard.results.items.last.resultType, 'color');

    final fees = dashboard.fees!;
    expect(fees.status, InstallmentStatus.upcoming);
    expect(fees.installment?.feeType, 'مصاريف التعليم والنشاط');
    expect(fees.installment?.label, 'قسط رابع');
    expect(fees.installment?.amount, 3000);
    expect(fees.installment?.dueDate, DateTime(2027, 2, 1));

    expect(dashboard.messages.total, 0);
  });

  test('parts left out: nothing yet', () {
    final dashboard = ChildDashboardModel.fromJson(const {});

    expect(dashboard.child, isNull);
    expect(dashboard.attendance.todayStatus, isNull);
    expect(dashboard.attendance.allowedAbsenceDays, 0);
    expect(dashboard.latestResult, isNull);
    expect(dashboard.fees, isNull);
    expect(dashboard.announcements.items, isEmpty);
    expect(dashboard.homework.items, isEmpty);
    expect(dashboard.results.items, isEmpty);
    expect(dashboard.messages.total, 0);
  });

  test('all paid: fees with no installment', () {
    final dashboard = ChildDashboardModel.fromJson(const {
      'fees': {'selection_status': 'PAID', 'selected_installment': null},
    });

    expect(dashboard.fees?.status, InstallmentStatus.paid);
    expect(dashboard.fees?.installment, isNull);
  });

  test('overdue fees: how many, and what they add up to', () {
    final dashboard = ChildDashboardModel.fromJson(const {
      'fees': {
        'selection_status': 'OVERDUE',
        'selected_installment': {
          'fee_type': 'مصاريف التعليم والنشاط',
          'label': 'قسط ثانى',
          'amount': 5000,
          'due_date': '2026-10-01',
        },
        'overdue_installments': [
          {'fee_type': 'مصاريف التعليم والنشاط', 'amount': 5000},
          {'fee_type': 'اشتراك الباص', 'amount': 2000},
        ],
        'overdue_count': 2,
        'overdue_total': 7000,
      },
    });

    expect(dashboard.fees?.overdueCount, 2);
    expect(dashboard.fees?.overdueTotal, 7000);
    expect(dashboard.fees?.hasOverdue, isTrue);
  });

  test('overdue fees without a count or total: added up from the list', () {
    final dashboard = ChildDashboardModel.fromJson(const {
      'fees': {
        'selection_status': 'OVERDUE',
        'overdue_installments': [
          {'amount': 5000},
          {'amount': 2000},
        ],
      },
    });

    expect(dashboard.fees?.overdueCount, 2);
    expect(dashboard.fees?.overdueTotal, 7000);
  });

  test('a result without its id is left out', () {
    final dashboard = ChildDashboardModel.fromJson(const {
      'results': {
        'latest': {'title': 'No id'},
        'items': [
          {'title': 'No id'},
          {'id': 5, 'title': 'Term 1'},
        ],
      },
    });

    expect(dashboard.latestResult, isNull);
    expect(dashboard.results.items.single.id, 5);
    // Not said: as many as came.
    expect(dashboard.results.total, 1);
  });
}
