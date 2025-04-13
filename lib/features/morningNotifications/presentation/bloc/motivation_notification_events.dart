import 'package:equatable/equatable.dart';

abstract class MotivationNotificationEvent extends Equatable {
  const MotivationNotificationEvent();

  @override
  List<Object> get props => [];
}

class FetchMotivationMessage extends MotivationNotificationEvent {}
