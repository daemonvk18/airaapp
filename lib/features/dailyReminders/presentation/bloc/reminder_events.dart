abstract class ReminderEvent {
  const ReminderEvent();

  @override
  // ignore: override_on_non_overriding_member
  List<Object> get props => [];
}

class LoadReminders extends ReminderEvent {
  const LoadReminders();
}

class AddReminder extends ReminderEvent {
  final String title;
  final String scheduledTime;

  const AddReminder({
    required this.title,
    required this.scheduledTime,
  });

  @override
  List<Object> get props => [title, scheduledTime];
}

class DeleteReminder extends ReminderEvent {
  final String reminderId;

  const DeleteReminder(this.reminderId);

  @override
  List<Object> get props => [reminderId];
}

class UpdateReminder extends ReminderEvent {
  final String reminderId;
  final String? title;
  final String? scheduledTime;
  final String? status;

  const UpdateReminder({
    required this.reminderId,
    this.title,
    this.scheduledTime,
    this.status,
  });

  @override
  List<Object> get props => [
        reminderId,
        title ?? '',
        scheduledTime ?? '',
        status ?? '',
      ];
}
