import 'package:airaapp/features/dailyReminders/domain/models/reminder_model.dart';

class ReminderModel extends ReminderEntity {
  ReminderModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.scheduledTime,
    required super.status,
    required super.isDue,
    super.generatedReminder,
    super.createdAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? json['generated_reminder'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      status: json['status'] ?? 'pending',
      isDue: json['is_due'] ?? false,
      generatedReminder: json['generated_reminder'],
      createdAt: json['created_at'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'scheduled_time': scheduledTime,
      'status': status,
    };
  }
}
