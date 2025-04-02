import 'dart:convert';
import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/core/network_service.dart';
import 'package:airaapp/features/chat/domain/model/chat_message.dart';
import 'package:airaapp/features/chat/domain/model/new_chat_session.dart';
import 'package:airaapp/features/chat/domain/repository/chat_message_repo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChatRepoImpl implements ChatRepo {
  //get the network service here
  final NetworkService networkService = NetworkService();
  //get the secure storage
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  @override
  Future<ChatMessage> sendmessage(
      {required String message, required String session_id}) async {
    print('this is my $session_id');
    final token = await secureStorage.read(key: 'session_token');
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.chatEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'session_id': session_id,
        }),
      );
      print(jsonDecode(response.body));
      print('sent the api call');
      // ignore: unnecessary_null_comparison
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        print(decodedResponse);
        return ChatMessage.fromJson(decodedResponse);
      } else {
        throw Exception("Empty response");
      }
    } catch (e) {
      throw Exception("Failed to send message: $e");
    }
  }

  @override
  Future<List<ChatMessage>> getSavedChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? chatJson = prefs.getStringList('chat_history');
      if (chatJson != null) {
        List<dynamic> decodedChats = jsonDecode(chatJson.toString());
        return decodedChats.map((chat) => ChatMessage.fromJson(chat)).toList();
      }
      return [];
    } catch (e) {
      print("Error loading chat: $e");
      return [];
    }
  }

  @override
  Future<void> saveChat(List<ChatMessage> chat) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> chatJson =
          chat.map((msg) => jsonEncode(msg.toJson())).toList();
      await prefs.setStringList('chat_history', chatJson);
    } catch (e) {
      print("Error saving chat: $e");
    }
  }

  // @override
  // Future<void> clearChatHistory() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('chat_history'); // Clears the saved chat history
  // }

  @override
  Future<NewChatSession> createNewSession() async {
    try {
      final response = await networkService.createNewSession();
      if (response.isNotEmpty) {
        print('new session created');
        print(response);
        return NewChatSession(
            sessionId: response['session_id'],
            sessionTitle: response['session_title']);
      } else {
        throw Exception('failed to create a new session');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
