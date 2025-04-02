import 'package:airaapp/features/chat/data/data_chat_repo.dart';
import 'package:airaapp/features/chat/domain/model/chat_message.dart';
import 'package:airaapp/features/chat/domain/repository/chat_message_repo.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_events.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepo repository;
  String? _currentSessionId;
  String? _currentSessionTitle;
  List<ChatMessage> _messages = [];

  ChatBloc(ChatRepoImpl chatRepoImpl, {required this.repository})
      : super(ChatInitial()) {
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessage>(_onSendMessage);
    on<CreateNewSessionEvent>(_onCreateNewSession);
    on<InitializeWithSession>(_onInitializeWithSession);
  }

  Future<void> _onInitializeWithSession(
    InitializeWithSession event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      _currentSessionId = event.sessionId;
      _messages = await repository.getSavedChat();
      // Load any existing messages for this session
      await _onLoadChatHistory(LoadChatHistory(), emit);
    } catch (e) {
      emit(ChatError(message: 'Failed to initialize session: $e'));
      // Fallback to new session if initialization fails
      add(CreateNewSessionEvent());
    }
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final messages = await repository.getSavedChat();
      emit(ChatLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(message: 'Failed to load history: $e'));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentSessionId == null) {
      emit(ChatError(message: 'no current session'));
      return;
    }

    final userMessage = ChatMessage(
        isUser: true,
        text: event.message,
        responseId: '',
        responseTime: 0.0,
        timestamp: DateTime.now());
    // Add user message immediately
    _updateMessages(
      emit,
      newMessages: [..._messages, userMessage],
      showThinking: true, // Show "Thinking..." placeholder
    );
    print(_currentSessionId);
    try {
      final aiMessage = await repository
          .sendmessage(
            message: event.message,
            session_id: _currentSessionId!,
          )
          .timeout(const Duration(seconds: 30));

      _updateMessages(
        emit,
        newMessages: [..._messages, aiMessage],
        showThinking: false, // Remove placeholder
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
      ));
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
    emit(ChatLoading());
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
    }
  }
}
