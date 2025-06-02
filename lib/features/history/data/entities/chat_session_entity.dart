import 'package:airaapp/features/history/domain/model/chat_session.dart';

class ChatSessionModel extends ChatSession {
  const ChatSessionModel({
    required String sessionId,
    required String title,
    required String createdAt,
  }) : super(sessionId: sessionId, title: title, createdAt: createdAt);

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
        sessionId: json['session_id'] ?? '',
        title: json['session_title'] ?? "New Chat",
        createdAt: json['created_at'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'session_title': title,
      'created_at': createdAt
    };
  }
}
