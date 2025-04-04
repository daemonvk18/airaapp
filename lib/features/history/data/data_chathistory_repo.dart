import 'package:airaapp/core/network_service.dart';
import 'package:airaapp/features/history/data/entities/chat_history_entity.dart';
import 'package:airaapp/features/history/data/entities/chat_session_entity.dart';
import 'package:airaapp/features/history/domain/model/chat_session.dart';
import 'package:airaapp/features/history/domain/repository/chat_history_repo.dart';

class DataChatHistoryRepo extends ChatRepository {
  final networkService = NetworkService();

  @override
  Future<List<ChatHistoryModel>> getChatHistory(String sessionId) async {
    try {
      print('my sessionId is $sessionId');
      final response = await networkService.getChatHistory(sessionId);
      if (response.containsKey('history') && response['history'] is List) {
        final history = response['history'] as List;
        return history.map((json) => ChatHistoryModel.fromJson(json)).toList();
      } else {
        throw Exception("Invalid response format for chat history");
      }
    } catch (e) {
      throw Exception('Failed to load chat history: ${e.toString()}');
    }
  }

  @override
  Future<List<ChatSession>> getChatSessions() async {
    try {
      final response = await networkService.getallSessions();
      if (response.containsKey('sessions') && response['sessions'] is List) {
        final sessions = response['sessions'] as List;
        return sessions.map((json) => ChatSessionModel.fromJson(json)).toList();
      } else {
        throw Exception("Invalid response format for chat sessions");
      }
    } catch (e) {
      throw Exception('Failed to load chat sessions: ${e.toString()}');
    }
  }
}
