import 'package:equatable/equatable.dart';

class ChatHistory extends Equatable {
  final String role;
  final String message;
  final DateTime createdAt;
  final String response_id;

  const ChatHistory(
      {required this.role,
      required this.message,
      required this.createdAt,
      required this.response_id});

  @override
  List<Object> get props => [role, message, createdAt];
}
