import 'package:airaapp/features/chat/domain/model/chat_message.dart';
import 'package:airaapp/features/chat/domain/model/new_chat_session.dart';

abstract class ChatRepo {
  Future<ChatMessage> sendmessage(
      {required String message, required String session_id});
  Future<void> saveChat(List<ChatMessage> chat);
  Future<List<ChatMessage>> getSavedChat();
  //Future<void> clearChatHistory();
  //function to create new chatsession
  Future<NewChatSession> createNewSession();
  //function load the feedbacks as well
  //Future<Map<String, bool>> loadFeedbackForMessages(List<ChatMessage> messages);
}
