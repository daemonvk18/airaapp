import 'package:airaapp/features/dailyReminders/domain/models/reminder_model.dart';

abstract class ReminderState {
  const ReminderState();

  List<Object> get props => [];
}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class RemindersLoaded extends ReminderState {
  final List<ReminderEntity> reminders;

  const RemindersLoaded(this.reminders);

  @override
  List<Object> get props => [reminders];
}

class ReminderOperationSuccess extends ReminderState {
  final String message;
  final ReminderEntity? reminder;

  const ReminderOperationSuccess(this.message, [this.reminder]);

  @override
  List<Object> get props => [message, reminder ?? ''];
}

class ReminderError extends ReminderState {
  final String message;

  const ReminderError(this.message);

  @override
  List<Object> get props => [message];
}
