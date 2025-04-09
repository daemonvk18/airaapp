import 'package:airaapp/features/dailyReminders/domain/repository/remider_repository.dart';
import 'package:airaapp/features/dailyReminders/presentation/bloc/reminder_events.dart';
import 'package:airaapp/features/dailyReminders/presentation/bloc/reminder_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository reminderRepository;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  ReminderBloc({
    required this.reminderRepository,
  }) : super(ReminderInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<AddReminder>(_onAddReminder);
    on<UpdateReminder>(_onUpdateReminder);
    on<DeleteReminder>(_onDeleteReminder);
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<ReminderState> emit,
  ) async {
    emit(ReminderLoading());
    try {
      final reminders = await reminderRepository.getReminders();
      emit(RemindersLoaded(reminders));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onAddReminder(
    AddReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      emit(ReminderLoading());
      final newReminder = await reminderRepository.addReminder(
        title: event.title,
        scheduledTime: event.scheduledTime,
      );

      // Get current state
      if (state is RemindersLoaded) {
        final currentReminders = (state as RemindersLoaded).reminders;
        emit(RemindersLoaded([...currentReminders, newReminder]));
      } else {
        emit(RemindersLoaded([newReminder]));
      }

      emit(
          ReminderOperationSuccess('Reminder added successfully', newReminder));

      // Optional: Reload from server to ensure consistency
      add(const LoadReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onUpdateReminder(
    UpdateReminder event,
    Emitter<ReminderState> emit,
  ) async {
    emit(ReminderLoading());
    try {
      final updatedReminder = await reminderRepository.updateReminder(
        reminderId: event.reminderId,
        title: event.title,
        scheduledTime: event.scheduledTime,
        status: event.status,
      );

      if (state is RemindersLoaded) {
        final currentReminders = (state as RemindersLoaded).reminders;
        final updatedList = currentReminders
            .map((r) => r.id == event.reminderId ? updatedReminder : r)
            .toList();
        emit(RemindersLoaded(updatedList));
      }

      emit(ReminderOperationSuccess(
          'Reminder updated successfully', updatedReminder));
      add(const LoadReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onDeleteReminder(
    DeleteReminder event,
    Emitter<ReminderState> emit,
  ) async {
    emit(ReminderLoading());
    try {
      await reminderRepository.deleteReminder(event.reminderId);

      // Update the state immediately by removing the deleted reminder
      if (state is RemindersLoaded) {
        final currentReminders = (state as RemindersLoaded).reminders;
        emit(RemindersLoaded(
            currentReminders.where((r) => r.id != event.reminderId).toList()));
      }

      emit(const ReminderOperationSuccess('Reminder deleted successfully'));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }
}
