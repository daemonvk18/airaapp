import 'package:airaapp/features/history/domain/model/chat_session.dart';

class ChatSessionModel extends ChatSession {
  const ChatSessionModel({
    required String sessionId,
    required String title,
  }) : super(sessionId: sessionId, title: title);

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      sessionId: json['session_id'] ?? '',
      title: json['session_title'] ?? "New Chat",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'session_title': title,
    };
  }
}
