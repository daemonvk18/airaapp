import 'dart:convert';

import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/core/network_service.dart';
import 'package:airaapp/features/chat/domain/model/chat_message.dart';
import 'package:airaapp/features/chat/domain/repository/chat_message_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepoImpl implements ChatRepo {
  //get the network service here
  final NetworkService networkService = NetworkService();
  @override
  Future<ChatMessage> sendmessage(String message) async {
    try {
      final response = await networkService
          .postChat(ApiConstants.chatEndpoint, {'message': message});
      // ignore: unnecessary_null_comparison
      if (response != null) {
        print(response);
        return ChatMessage.fromJson(response);
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

  @override
  Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history'); // Clears the saved chat history
  }
}
