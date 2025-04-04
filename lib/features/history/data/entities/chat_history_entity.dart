import 'package:airaapp/features/history/domain/model/chat_history.dart';

class ChatHistoryModel extends ChatHistory {
  const ChatHistoryModel(
      {required String role,
      required String message,
      required DateTime createdAt,
      required String responseId})
      : super(
            role: role,
            message: message,
            createdAt: createdAt,
            response_id: responseId);

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
        role: json['role'] ?? '',
        message: json['content'] ?? "",
        createdAt:
            DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
        responseId: json['response_id'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': message,
      'created_at': createdAt.toIso8601String(),
      'response_id': response_id
    };
  }
}
