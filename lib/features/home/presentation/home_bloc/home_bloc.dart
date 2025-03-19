import 'package:airaapp/features/home/presentation/home_events/home_event.dart';
import 'package:airaapp/features/home/presentation/home_states/home_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeTabChanged(0)) {
    on<ChangeTab>((event, emit) {
      emit(HomeTabChanged(event.index)); // Change bottom nav tab
    });

    on<NavigateToChat>((event, emit) {
      emit(ChatPageOpened()); // Navigate to chat page
    });
    on<ResetHomeState>((event, emit) {
      emit(HomeInitial()); // Reset state when back to HomePage
    });
  }
}
