import 'package:airaapp/features/history/domain/model/chat_history.dart';
import 'package:airaapp/features/history/domain/model/chat_session.dart';
import 'package:equatable/equatable.dart';

abstract class ChatHistoryState extends Equatable {
  @override
  List<Object> get props => [];
}

class ChatHistoryInitial extends ChatHistoryState {}

class ChatHistoryLoading extends ChatHistoryState {}

class ChatSessionsLoaded extends ChatHistoryState {
  final List<ChatSession> sessions;

  ChatSessionsLoaded(this.sessions);

  @override
  List<Object> get props => [sessions];
}

class ChatHistoryLoaded extends ChatHistoryState {
  final List<ChatHistory> history;

  ChatHistoryLoaded(this.history);

  @override
  List<Object> get props => [history];
}

class ChatHistoryError extends ChatHistoryState {
  final String message;

  ChatHistoryError(this.message);

  @override
  List<Object> get props => [message];
}
