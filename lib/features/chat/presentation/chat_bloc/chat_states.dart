import 'package:airaapp/features/chat/domain/model/chat_message.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

//intial state
class ChatInitial extends ChatState {}

//loading state
class ChatLoading extends ChatState {}

//got the message state
class ChatLoaded extends ChatState {
  final List<ChatMessage>? messages;
  final String? sessionId;
  final String? sessionTitle;
  ChatLoaded({this.messages, this.sessionId, this.sessionTitle});

  @override
  List<Object?> get props => [messages, sessionId, sessionTitle];
}

//chat error state
class ChatError extends ChatState {
  final String message;
  ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}
