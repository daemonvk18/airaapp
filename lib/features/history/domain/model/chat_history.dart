import 'package:equatable/equatable.dart';

class ChatHistory extends Equatable {
  final String role;
  final String message;

  const ChatHistory({required this.role, required this.message});

  @override
  List<Object> get props => [role, message];
}
