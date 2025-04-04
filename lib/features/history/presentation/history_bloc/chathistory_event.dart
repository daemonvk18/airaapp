import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadChatSessions extends ChatEvent {}

class LoadChatHistoryEvent extends ChatEvent {
  final String sessionId;

  LoadChatHistoryEvent(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}
