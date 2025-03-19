import 'package:airaapp/features/history/domain/repository/chat_history_repo.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_event.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatHistoryBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatrepo;
  ChatHistoryBloc({required this.chatrepo}) : super(ChatInitial()) {
    on<LoadChatSessions>((event, emit) async {
      emit(ChatLoading());
      try {
        final sessions = await chatrepo.getChatSessions();
        emit(ChatSessionsLoaded(sessions));
      } catch (e) {
        emit(ChatError("Failed to load chat sessions"));
      }
    });

    on<LoadChatHistory>((event, emit) async {
      emit(ChatLoading());
      try {
        final history = await chatrepo.getChatHistory(event.sessionId);
        emit(ChatHistoryLoaded(history));
      } catch (e) {
        emit(ChatError("Failed to load chat history"));
      }
    });
  }
}
