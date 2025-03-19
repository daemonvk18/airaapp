import 'package:airaapp/features/chat/domain/model/chat_message.dart';

abstract class ChatRepo {
  Future<ChatMessage> sendmessage(String message);
  Future<void> saveChat(List<ChatMessage> chat);
  Future<List<ChatMessage>> getSavedChat();
  Future<void> clearChatHistory();
}
