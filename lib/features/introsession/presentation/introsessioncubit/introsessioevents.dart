abstract class IntroSessionEvent {}

class StartIntroSession extends IntroSessionEvent {}

class SendIntroMessage extends IntroSessionEvent {
  final String message;
  SendIntroMessage({required this.message});
}
