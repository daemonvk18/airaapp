import 'package:airaapp/features/history/domain/model/chat_history.dart';
import 'package:airaapp/features/history/domain/model/chat_session.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatSessionsLoaded extends ChatState {
  final List<ChatSession> sessions;

  ChatSessionsLoaded(this.sessions);

  @override
  List<Object> get props => [sessions];
}

class ChatHistoryLoaded extends ChatState {
  final List<ChatHistory> history;

  ChatHistoryLoaded(this.history);

  @override
  List<Object> get props => [history];
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);

  @override
  List<Object> get props => [message];
}
