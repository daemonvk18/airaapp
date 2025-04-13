import 'dart:async';
import 'package:airaapp/features/morningNotifications/domain/repository/motivation_repo.dart';
import 'package:airaapp/features/morningNotifications/presentation/bloc/motivation_notification_events.dart';
import 'package:airaapp/features/morningNotifications/presentation/bloc/motivation_notification_states.dart';
import 'package:bloc/bloc.dart';

class MotivationNotificationBloc
    extends Bloc<MotivationNotificationEvent, MotivationNotificationState> {
  final MotivationRepository motivationRepository;
  final String userId;

  MotivationNotificationBloc({
    required this.motivationRepository,
    required this.userId,
  }) : super(MotivationNotificationInitial()) {
    on<FetchMotivationMessage>(_onFetchMotivationMessage);
  }

  Future<void> _onFetchMotivationMessage(
    FetchMotivationMessage event,
    Emitter<MotivationNotificationState> emit,
  ) async {
    emit(MotivationNotificationLoading());
    try {
      final message = await motivationRepository.getMotivationMessage();
      emit(MotivationNotificationLoaded(message: message));
    } catch (e) {
      emit(MotivationNotificationError(message: e.toString()));
    }
  }
}
