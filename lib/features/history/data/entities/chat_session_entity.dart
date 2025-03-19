import 'package:airaapp/features/history/domain/model/chat_session.dart';

class ChatSessionModel extends ChatSession {
  const ChatSessionModel({
    required String sessionId,
    required String title,
    required DateTime createdAt,
  }) : super(sessionId: sessionId, title: title, createdAt: createdAt);

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      sessionId: json['session_id'] ?? '',
      title: json['title'] ?? "",
      createdAt: DateTime.parse(json['created_at']['\$date'] ?? DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
