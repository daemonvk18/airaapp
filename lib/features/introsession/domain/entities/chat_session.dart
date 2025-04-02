import 'package:airaapp/features/introsession/domain/entities/chat_message.dart';

class ChatSession {
  final String sessionId;
  final String? sessionTitle;
  final List<Message> messages;
  final int aiResponseCount;

  ChatSession({
    required this.sessionId,
    this.sessionTitle,
    required this.messages,
    required this.aiResponseCount,
  });

  ChatSession copyWith({
    String? sessionId,
    String? sessionTitle,
    List<Message>? messages,
    int? aiResponseCount,
  }) {
    return ChatSession(
      sessionId: sessionId ?? this.sessionId,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      messages: messages ?? this.messages,
      aiResponseCount: aiResponseCount ?? this.aiResponseCount,
    );
  }
}
