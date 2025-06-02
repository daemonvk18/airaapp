import 'package:equatable/equatable.dart';

class ChatSession extends Equatable {
  final String sessionId;
  final String title;
  final String createdAt;

  const ChatSession(
      {required this.sessionId, required this.title, required this.createdAt});

  @override
  List<Object> get props => [
        sessionId,
        title,
      ];
}
