import 'package:airaapp/features/history/domain/model/chat_history.dart';

class ChatHistoryModel extends ChatHistory {
  const ChatHistoryModel({required String role, required String message})
      : super(role: role, message: message);

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      role: json['role'] ?? '',
      message: json['message'] is Map<String, dynamic>
          ? json['message']['message']
          : json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'message': message,
    };
  }
}
