import 'package:airaapp/features/history/domain/model/chat_history.dart';
import 'package:airaapp/features/history/domain/model/chat_session.dart';

abstract class ChatRepository {
  Future<List<ChatSession>> getChatSessions();
  Future<List<ChatHistory>> getChatHistory(String sessionId);
  Future<String> deleteChatSession({required String sessionId});
}
