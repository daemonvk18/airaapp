import 'package:equatable/equatable.dart';

abstract class MotivationNotificationState extends Equatable {
  @override
  List<Object> get props => [];
}

class MotivationNotificationInitial extends MotivationNotificationState {}

class MotivationNotificationLoading extends MotivationNotificationState {}

class MotivationNotificationLoaded extends MotivationNotificationState {
  final String message;

  MotivationNotificationLoaded({required this.message});

  @override
  List<Object> get props => [message];
}

class MotivationNotificationError extends MotivationNotificationState {
  final String message;

  MotivationNotificationError({required this.message});

  @override
  List<Object> get props => [message];
}
