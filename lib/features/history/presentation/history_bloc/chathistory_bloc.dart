import 'package:airaapp/features/history/data/data_chathistory_repo.dart';
import 'package:airaapp/features/history/domain/repository/chat_history_repo.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_event.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatHistoryBloc extends Bloc<ChatEvent, ChatHistoryState> {
  final ChatRepository chatrepo;
  ChatHistoryBloc(DataChatHistoryRepo dataChatHistoryRepo,
      {required this.chatrepo})
      : super(ChatHistoryInitial()) {
    on<LoadChatSessions>((event, emit) async {
      emit(ChatHistoryLoading());
      try {
        print('calling the sessions');
        final sessions = await chatrepo.getChatSessions();
        print('got the session properly');
        print('these are my sessions $sessions');
        print('emitted');
        emit(ChatSessionsLoaded(sessions));
      } catch (e) {
        emit(ChatHistoryError("Failed to load chat sessions"));
      }
    });

    on<LoadChatHistoryEvent>((event, emit) async {
      emit(ChatHistoryLoading());
      try {
        final history = await chatrepo.getChatHistory(event.sessionId);
        emit(ChatHistoryLoaded(history));
      } catch (e) {
        emit(ChatHistoryError("Failed to load chat history"));
      }
    });
  }
}
