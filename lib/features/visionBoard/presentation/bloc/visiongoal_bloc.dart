import 'package:airaapp/features/visionBoard/domain/Repository/vision_board_repo.dart';
import 'package:airaapp/features/visionBoard/presentation/bloc/visiongoal_events.dart';
import 'package:airaapp/features/visionBoard/presentation/bloc/visiongoal_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VisionBoardBloc extends Bloc<VisionBoardEvent, VisionBoardState> {
  final VisionBoardRepo repository;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  VisionBoardBloc({
    required this.repository,
  }) : super(VisionBoardInitial()) {
    on<LoadVisionGoals>(_onLoadVisionGoals);
    on<AddVisionGoal>(_onAddVisionGoal);
  }

  Future<void> _onLoadVisionGoals(
    LoadVisionGoals event,
    Emitter<VisionBoardState> emit,
  ) async {
    emit(VisionBoardLoading());
    try {
      final goals = await repository.getdreams();

      if (goals.isEmpty) {
        emit(VisionBoardEmpty());
      } else {
        emit(VisionBoardLoaded(goals));
      }
    } catch (e) {
      emit(VisionBoardError(e.toString()));
    }
  }

  Future<void> _onAddVisionGoal(
    AddVisionGoal event,
    Emitter<VisionBoardState> emit,
  ) async {
    try {
      emit(VisionBoardLoading()); // Show loading state
      //final userId = await secureStorage.read(key: 'user_id') ?? '';
      // ignore: unused_local_variable
      final newGoal = await repository.adddreams(event.goal);

      // Get fresh list to ensure we have the latest data
      final updatedGoals = await repository.getdreams();

      emit(VisionBoardLoaded(updatedGoals));
    } catch (e) {
      emit(VisionBoardError(e.toString()));
      // Re-emit the previous state to maintain UI
      if (state is VisionBoardLoaded) {
        emit(state);
      }
    }
  }
}
