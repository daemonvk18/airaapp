import 'dart:convert';

import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/core/network_service.dart';
import 'package:airaapp/features/history/data/entities/chat_history_entity.dart';
import 'package:airaapp/features/history/data/entities/chat_session_entity.dart';
import 'package:airaapp/features/history/domain/model/chat_session.dart';
import 'package:airaapp/features/history/domain/repository/chat_history_repo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DataChatHistoryRepo extends ChatRepository {
  final networkService = NetworkService();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

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

  @override
  Future<String> deleteChatSession({required String sessionId}) async {
    final sesionToken = await secureStorage.read(key: 'session_token');
    try {
      final response = await http.delete(
          Uri.parse(
              '${ApiConstants.deleteChatSessionEndpoint}?session_id=${sessionId}'),
          headers: {
            "Content-Type": "application/json",
            if (sesionToken != null) "Authorization": "Bearer $sesionToken",
          });
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        print(decodedResponse);
        return decodedResponse['message'];
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
