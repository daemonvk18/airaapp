import 'package:equatable/equatable.dart';

abstract class ReminderEvent extends Equatable {
  @override
  // ignore: override_on_non_overriding_member
  List<Object> get props => [];
}

class LoadReminders extends ReminderEvent {
  LoadReminders();
}

class AddReminder extends ReminderEvent {
  final String title;
  final String scheduledTime;

  AddReminder({
    required this.title,
    required this.scheduledTime,
  });

  @override
  List<Object> get props => [title, scheduledTime];
}

class DeleteReminder extends ReminderEvent {
  final String reminderId;

  DeleteReminder(this.reminderId);

  @override
  List<Object> get props => [reminderId];
}

class UpdateReminder extends ReminderEvent {
  final String reminderId;
  final String? title;
  final String? scheduledTime;
  final String? status;

  UpdateReminder({
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
