import 'package:airaapp/features/introsession/domain/entities/chat_session.dart';

abstract class IntroChatState {}

class IntroChatInitial extends IntroChatState {}

class IntroChatLoading extends IntroChatState {}

class IntroChatMessageReceived extends IntroChatState {
  final ChatSession chatSession;
  final bool isIntroComplete;
  IntroChatMessageReceived(
      {required this.chatSession, this.isIntroComplete = false});
}

class IntroChatCompleted extends IntroChatState {
  final String? sessionTitle;
  IntroChatCompleted({this.sessionTitle});
}

class IntroChatError extends IntroChatState {
  final String message;
  IntroChatError({required this.message});
}
