import 'package:airaapp/features/introsession/domain/entities/chat_session.dart';

abstract class IntrosessionRepo {
  //intro message function...
  Future<ChatSession> startIntroSession();
  //send message function just for the 7 ai responses...
  Future<ChatSession> sendMessage({
    required String sessionId,
    required String message,
    required ChatSession currentSession,
  });
}
