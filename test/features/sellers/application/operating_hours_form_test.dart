import 'package:africaonlinestores/features/sellers/application/controllers/operating_hours_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OperatingHoursForm', () {
    test('serializes canonical full weekday names for seller API', () {
      final form = OperatingHoursForm(
        dayEnabled: <String, bool>{
          'Monday': true,
          'Tuesday': false,
          'Wednesday': false,
          'Thursday': false,
          'Friday': false,
          'Saturday': false,
          'Sunday': false,
        },
        openTimes: <String, TimeOfDay>{
          'Monday': const TimeOfDay(hour: 8, minute: 30),
        },
        closeTimes: <String, TimeOfDay>{
          'Monday': const TimeOfDay(hour: 17, minute: 45),
        },
      );

      final payload = form.toApiPayload();

      expect(payload.first, <String, dynamic>{
        'day_of_week': 'Monday',
        'is_open': 1,
        'open_time': '08:30:00',
        'close_time': '17:45:00',
      });
      expect(payload.map((row) => row['day_of_week']), <String>[
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ]);
      expect(payload[1], <String, dynamic>{
        'day_of_week': 'Tuesday',
        'is_open': 0,
      });
    });

    test('hydrates legacy abbreviated days without emitting them again', () {
      final form = OperatingHoursForm();

      form.hydrate(<Object?>[
        <String, dynamic>{
          'day_of_week': 'Mon',
          'is_open': 1,
          'open_time': '07:00:00',
          'close_time': '16:00:00',
        },
      ]);

      expect(form.dayEnabled['Monday'], isTrue);
      expect(form.openTimes['Monday'], const TimeOfDay(hour: 7, minute: 0));
      expect(form.closeTimes['Monday'], const TimeOfDay(hour: 16, minute: 0));
      expect(form.toApiPayload().first['day_of_week'], 'Monday');
    });
  });
}
