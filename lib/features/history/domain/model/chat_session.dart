import 'package:equatable/equatable.dart';

class ChatSession extends Equatable {
  final String sessionId;
  final String title;

  const ChatSession({
    required this.sessionId,
    required this.title,
  });

  @override
  List<Object> get props => [
        sessionId,
        title,
      ];
}
