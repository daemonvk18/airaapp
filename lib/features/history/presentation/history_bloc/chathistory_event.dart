import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadChatSessions extends ChatEvent {}

class LoadChatHistory extends ChatEvent {
  final String sessionId;

  LoadChatHistory(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}
