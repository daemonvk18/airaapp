import 'dart:math';
import 'package:airaapp/features/chat/data/data_chat_repo.dart';
import 'package:airaapp/features/chat/domain/model/chat_message.dart';
import 'package:airaapp/features/chat/domain/repository/chat_message_repo.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_events.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_states.dart';
import 'package:airaapp/features/history/data/data_chathistory_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepo repository;
  String? _currentSessionId;
  String? _currentSessionTitle;
  final DataChatHistoryRepo chatHistoryRepo;
  List<ChatMessage> _messages = [];
  //Map<String, bool> _feedbackMap = {}; // Store feedback states

  ChatBloc(ChatRepoImpl chatRepoImpl,
      {required this.repository, required this.chatHistoryRepo})
      : super(ChatInitial()) {
    //on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessage>(_onSendMessage);
    on<CreateNewSessionEvent>(_onCreateNewSession);
    on<InitializeWithSession>(_onInitializeWithSession);
    //on<LoadFeedbackForMessages>(_onLoadFeedbackForMessages);
  }

  Future<void> _onInitializeWithSession(
    InitializeWithSession event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      _currentSessionId = event.sessionId;
      // First try to load from API
      try {
        // Use history repository to load messages
        final history = await chatHistoryRepo.getChatHistory(event.sessionId);
        _messages = history
            .map((h) => ChatMessage(
                isUser: h.role == 'User',
                text: h.message,
                responseId: h.response_id,
                responseTime:
                    0.0, // You may need to map this from history if available
                timestamp: h.createdAt,
                isFromHistory: true))
            .toList();

        emit(ChatLoaded(
          messages: _messages,
          sessionId: _currentSessionId,
          sessionTitle: _currentSessionTitle,
        ));

        // Save to local storage as backup
        await repository.saveChat(_messages);
      } catch (apiError) {
        // Fallback to local storage if API fails
        print("API Error: $apiError. Falling back to local storage.");
        _messages = await repository.getSavedChat();
        emit(ChatLoaded(
          messages: _messages,
          sessionId: _currentSessionId,
          sessionTitle: _currentSessionTitle,
        ));
      }

      // Load any existing messages for this session
      print('Session initialized with ${_messages.length} messages');
    } catch (e) {
      emit(ChatError(message: 'Failed to initialize session: $e'));
      // Instead of creating new session, just keep the current state
      // or emit an empty loaded state
    }
  }

  // Future<void> _onLoadChatHistory(
  //   LoadChatHistory event,
  //   Emitter<ChatState> emit,
  // ) async {
  //   emit(ChatLoading());
  //   try {
  //     final messages = await repository.getSavedChat();
  //     emit(ChatLoaded(messages: messages));
  //   } catch (e) {
  //     emit(ChatError(message: 'Failed to load history: $e'));
  //   }
  // }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentSessionId == null) {
      emit(ChatError(message: 'no current session'));
      return;
    }

    // 1. Add user message immediately
    final userMessage = ChatMessage(
        isUser: true,
        text: event.message,
        responseId: '',
        responseTime: 0.0,
        timestamp: DateTime.now(),
        isFromHistory: false);

    // 2. Show user message + thinking indicator
    _updateMessages(
      emit,
      newMessages: [..._messages, userMessage],
      showThinking: true, // Show "Thinking..." placeholder
    );
    try {
      // 3. Start tracking when thinking was shown
      final thinkingStartTime = DateTime.now();
      // 4. Get AI response
      final aiMessage = await repository
          .sendmessage(
            message: event.message,
            session_id: _currentSessionId!,
          )
          .timeout(const Duration(seconds: 30));

      // 5. Calculate remaining thinking time
      final thinkingDuration = aiMessage.responseTime;
      final elapsed =
          DateTime.now().difference(thinkingStartTime).inMilliseconds / 1000;
      final remainingTime = max(0, thinkingDuration - elapsed);

      // 6. Wait remaining time if needed
      if (remainingTime > 0) {
        await Future.delayed(
            Duration(milliseconds: (remainingTime * 1000).toInt()));
      }
      // 7. Replace thinking with actual response
      _updateMessages(
        emit,
        newMessages: [
          ..._messages.where((m) => m.text != 'Thinking...'),
          aiMessage
        ],
        showThinking: false,
      );
      await repository.saveChat(_messages);
    } catch (e) {
      _updateMessages(
        emit,
        newMessages: _messages.where((m) => m.text != 'Thinking...').toList(),
      );
      emit(ChatError(
          message:
              'Failed to get AI response: $e')); // Revert to previous state
    }
  }

  // ========== Helper Methods ==========
  void _updateMessages(
    Emitter<ChatState> emit, {
    required List<ChatMessage> newMessages,
    bool showThinking = false,
  }) {
    _messages = newMessages;

    if (showThinking) {
      _messages.add(ChatMessage(
          isUser: false,
          text: 'Thinking...',
          responseId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          responseTime: 0.0,
          timestamp: DateTime.now(),
          isFromHistory: false));
    }

    emit(ChatLoaded(
      messages: List.from(_messages),
      sessionId: _currentSessionId,
      sessionTitle: _currentSessionTitle,
    ));
  }

  Future<void> _onCreateNewSession(
    CreateNewSessionEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoading) {
      emit(ChatLoading());
    }
    try {
      final session = await repository.createNewSession();
      _currentSessionId = session.sessionId;
      _currentSessionTitle = session.sessionTitle;
      _messages = [];
      print('new session created');
      emit(ChatLoaded(
        messages: _messages,
        sessionId: session.sessionId,
        sessionTitle: session.sessionTitle,
      ));
    } catch (e) {
      emit(ChatError(message: 'Failed to create session: $e'));
      // Re-emit the previous state so we don't get stuck in error state
    }
  }
}
