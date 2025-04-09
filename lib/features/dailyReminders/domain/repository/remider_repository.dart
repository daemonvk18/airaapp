import 'package:airaapp/features/dailyReminders/domain/models/reminder_model.dart';

abstract class ReminderRepository {
  Future<List<ReminderEntity>> getReminders();
  Future<ReminderEntity> addReminder({
    required String title,
    required String scheduledTime,
  });
  Future<ReminderEntity> updateReminder({
    required String reminderId,
    String? title,
    String? scheduledTime,
    String? status,
  });
  Future<void> deleteReminder(String reminderId);
}
