import 'dart:convert';
import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/core/network_service.dart';
import 'package:airaapp/features/introsession/domain/entities/chat_message.dart';
import 'package:airaapp/features/introsession/domain/entities/chat_session.dart';
import 'package:airaapp/features/introsession/domain/models/chat_response.dart';
import 'package:airaapp/features/introsession/domain/models/intro_session_response.dart';
import 'package:airaapp/features/introsession/domain/repository/introsessionRepo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class IntrosessionImpl implements IntrosessionRepo {
  //get the networkService here....
  final NetworkService networkService = NetworkService();

  //ge the secure storage here
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  //step 2: api called after the first message from the ai
  @override
  Future<ChatSession> sendMessage(
      {required String sessionId,
      required String message,
      required ChatSession currentSession}) async {
    final token = await secureStorage.read(key: 'session_token');
    try {
      // Add user message to the session
      final updatedMessages = List<Message>.from(currentSession.messages)
        ..add(
          Message(
            id: 'user_${DateTime.now().millisecondsSinceEpoch}',
            content: message,
            isUser: true,
            timestamp: DateTime.now(),
          ),
        );
      // now send this to the api and get the response
      final response = await http.post(Uri.parse(ApiConstants.chatEndpoint),
          headers: {
            "Content-Type": "application/json",
            if (token != null)
              "Authorization": "Bearer $token", // Add token if available
          },
          body: jsonEncode({
            "session_id": sessionId,
            "message": message,
          }));
      print(response);
      final decodedresponse = jsonDecode(response.body);
      print(decodedresponse['message']);
      final chatResponse = ChatResponse.fromJson(decodedresponse);

      // Add AI response to the session
      updatedMessages.add(
        Message(
          id: chatResponse.responseId,
          content: chatResponse.message,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      return currentSession.copyWith(
        messages: updatedMessages,
        sessionTitle: chatResponse.sessionTitle,
        aiResponseCount: currentSession.aiResponseCount + 1,
      );
    } catch (e) {
      throw Exception("Failed to send intro message: $e");
    }
  }

  @override
  Future<ChatSession> startIntroSession() async {
    final token = await secureStorage.read(key: 'session_token');
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.introSessionEndpoint),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      final decodedResponse = jsonDecode(response.body);
      final introResponse = IntroSessionResponse.fromJson(decodedResponse);
      //return the chat session
      return ChatSession(
          sessionId: introResponse.sessionId,
          messages: [
            Message(
                id: "ai_${DateTime.now().millisecondsSinceEpoch}",
                content: introResponse.message,
                isUser: false,
                timestamp: DateTime.now())
          ],
          aiResponseCount: 1);
    } catch (e) {
      throw Exception("Failed to start intro session: $e");
    }
  }
}
