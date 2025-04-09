class ReminderEntity {
  final String id;
  final String userId;
  final String title;
  final String scheduledTime;
  final String status;
  final bool isDue;
  final String? generatedReminder;
  final String? createdAt;

  ReminderEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.scheduledTime,
    required this.status,
    required this.isDue,
    this.generatedReminder,
    this.createdAt,
  });
}
