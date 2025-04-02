import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadChatHistory extends ChatEvent {}

class ClearChatHistory extends ChatEvent {}

class CreateNewSessionEvent extends ChatEvent {}

class InitializeWithSession extends ChatEvent {
  final String sessionId;

  InitializeWithSession(this.sessionId);
}

class SendMessage extends ChatEvent {
  final String message;
  final String session_id;
  SendMessage(this.message, this.session_id);

  @override
  List<Object?> get props => [message];
}
