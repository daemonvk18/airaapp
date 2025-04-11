import 'package:airaapp/features/dailyReminders/domain/models/reminder_model.dart';
import 'package:equatable/equatable.dart';

abstract class ReminderState extends Equatable {
  List<Object> get props => [];
}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class RemindersLoaded extends ReminderState {
  final List<ReminderEntity> reminders;

  RemindersLoaded(this.reminders);

  @override
  List<Object> get props => [reminders];
}

class ReminderEmpty extends ReminderState {}

class ReminderOperationSuccess extends ReminderState {
  final String message;
  final ReminderEntity? reminder;

  ReminderOperationSuccess(this.message, [this.reminder]);

  @override
  List<Object> get props => [message, reminder ?? ''];
}

class ReminderError extends ReminderState {
  final String message;

  ReminderError(this.message);

  @override
  List<Object> get props => [message];
}
