import 'package:airaapp/features/introsession/data/introsessionImpl.dart';
import 'package:airaapp/features/introsession/domain/entities/chat_session.dart';
import 'package:airaapp/features/introsession/domain/repository/introsessionRepo.dart';
import 'package:airaapp/features/introsession/presentation/introsessioncubit/introsessioevents.dart';
import 'package:airaapp/features/introsession/presentation/introsessioncubit/introsessionstates.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class IntroSessionBloc extends Bloc<IntroSessionEvent, IntroChatState> {
  //get the introRepo....
  final IntrosessionRepo introRepo;

  //get the flutter secure storage
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  //ge the currentchat session
  ChatSession? _currentSession;

  IntroSessionBloc(IntrosessionImpl introsessionImpl, {required this.introRepo})
      : super(IntroChatInitial()) {
    on<StartIntroSession>(_onStartChat);
    on<SendIntroMessage>(_onSendMessage);
  }

  //_startChat function....
  Future<void> _onStartChat(
    StartIntroSession event,
    Emitter<IntroChatState> emit,
  ) async {
    emit(IntroChatLoading());
    try {
      final token = await secureStorage.read(key: 'emailid');
      final isIntroComplete =
          await secureStorage.read(key: '${token}intro_completed');
      if (isIntroComplete == 'true') {
        // If intro is complete, we might want to load a different state
        // or skip the intro. Adjust based on your needs.
        emit(IntroChatMessageReceived(
          chatSession: ChatSession(
            sessionId: 'existing-session',
            messages: [],
            aiResponseCount: 0,
          ),
          isIntroComplete: true,
        ));
      } else {
        _currentSession = await introRepo.startIntroSession();
        emit(IntroChatMessageReceived(chatSession: _currentSession!));
      }
    } catch (e) {
      emit(IntroChatError(message: e.toString()));
    }
  }

  //_onSendMessage function....
  Future<void> _onSendMessage(
    SendIntroMessage event,
    Emitter<IntroChatState> emit,
  ) async {
    if (_currentSession == null) return;

    emit(IntroChatLoading());
    try {
      final emailid = await secureStorage.read(key: 'emailid');
      _currentSession = await introRepo.sendMessage(
        sessionId: _currentSession!.sessionId,
        message: event.message,
        currentSession: _currentSession!,
      );

      if (_currentSession!.aiResponseCount >= 7) {
        // Mark intro as complete in secure storage
        await secureStorage.write(
            key: '${emailid}intro_completed', value: 'true');
        emit(IntroChatCompleted(
            sessionTitle: _currentSession!.sessionTitle ?? "chat_completed"));
      } else {
        emit(IntroChatMessageReceived(chatSession: _currentSession!));
      }
    } catch (e) {
      emit(IntroChatError(message: e.toString()));
    }
  }
}
