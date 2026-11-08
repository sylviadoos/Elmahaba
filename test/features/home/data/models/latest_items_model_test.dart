import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_type.dart';
import 'package:al_mahhaba_school/features/home/data/models/announcement_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/latest_items_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/latest_result_model.dart';
import 'package:al_mahhaba_school/features/homework/data/models/homework_model.dart';

void main() {
  group('LatestItemsModel.fromJson', () {
    test('reads the latest announcements', () {
      final latest = LatestItemsModel.fromJson(const {
        'status': 'success',
        'data': [
          {
            'id': 2,
            'title': 'اجازه بمناسبه عيد الام',
            'body': 'يوم السبت الموافق 7-11 اجازه بمناسبه عيد الام',
            'published_at': '2026-11-05T10:07:13+00:00',
            'expires_at': '2026-11-12T13:55:00+00:00',
            'expired': false,
            'edited': true,
            'last_updated': '2026-11-05T11:22:24+00:00',
            'attachments': [],
            'scope': 'general',
            'audience': {
              'type': 'all',
              'name': 'All parents',
              'name_ar': 'كل أولياء الأمور',
            },
            'chat_key': 'event:38',
            'is_read': false,
          },
        ],
        'meta': {'limit': 3, 'total': 3, 'unread': 1},
      }, AnnouncementModel.fromJson);

      expect(latest.total, 3);
      expect(latest.unread, 1);
      final announcement = latest.items.single;
      expect(announcement.id, 2);
      expect(announcement.title, 'اجازه بمناسبه عيد الام');
      expect(
        announcement.body,
        'يوم السبت الموافق 7-11 اجازه بمناسبه عيد الام',
      );
      expect(announcement.publishedAt, DateTime.utc(2026, 11, 5, 10, 7, 13));
      expect(announcement.expiresAt, DateTime.utc(2026, 11, 12, 13, 55));
      expect(announcement.isExpired, isFalse);
      expect(announcement.isEdited, isTrue);
      expect(announcement.attachments, isEmpty);
      expect(announcement.audience?.type, ChatAudienceType.all);
      expect(announcement.audience?.nameAr, 'كل أولياء الأمور');
      expect(announcement.chatKey, 'event:38');
      expect(announcement.isRead, isFalse);
    });

    test('reads the latest results', () {
      final latest = LatestItemsModel.fromJson(const {
        'status': 'success',
        'data': [
          {
            'id': 280,
            'title': 'تيسسستتت',
            'academic_year': '2026-2027',
            'result_type': 'value and color',
            'published_at': '2026-11-04T17:48:00+00:00',
            'publication_id': 46,
            'chat_key': 'event:34',
            'is_read': true,
          },
        ],
        'meta': {'limit': 3, 'total': 7, 'unread': 0},
      }, LatestResultModel.fromJson);

      expect(latest.total, 7);
      expect(latest.unread, 0);
      final result = latest.items.single;
      expect(result.id, 280);
      expect(result.title, 'تيسسستتت');
      expect(result.academicYear, '2026-2027');
      expect(result.publishedAt, DateTime.utc(2026, 11, 4, 17, 48));
      expect(result.isRead, isTrue);
    });

    test('reads no homework', () {
      final latest = LatestItemsModel.fromJson(const {
        'status': 'success',
        'data': [],
        'meta': {'limit': 3, 'total': 0, 'unread': 0},
      }, HomeworkModel.fromJson);

      expect(latest.items, isEmpty);
      expect(latest.total, 0);
      expect(latest.unread, 0);
    });

    test('counts what it got when there is no meta', () {
      final latest = LatestItemsModel.fromJson(const {
        'data': [
          {'id': 1, 'title': 'A', 'body': 'B'},
        ],
      }, AnnouncementModel.fromJson);

      expect(latest.total, 1);
      expect(latest.unread, 0);
      // Not said: nothing to mark.
      expect(latest.items.single.isRead, isTrue);
    });
  });
}
