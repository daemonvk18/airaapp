import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadChatHistory extends ChatEvent {}

class ClearChatHistory extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String message;
  SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}
