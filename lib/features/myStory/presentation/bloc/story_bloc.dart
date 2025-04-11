import 'dart:async';
import 'package:airaapp/features/myStory/domain/repository/story_repo.dart';
import 'package:airaapp/features/myStory/presentation/bloc/story_events.dart';
import 'package:airaapp/features/myStory/presentation/bloc/story_states.dart';
import 'package:bloc/bloc.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final StoryRepository storyRepository;

  StoryBloc({required this.storyRepository}) : super(StoryInitial()) {
    on<GenerateStory>(_onGenerateStory);
  }

  Future<void> _onGenerateStory(
    GenerateStory event,
    Emitter<StoryState> emit,
  ) async {
    emit(StoryLoading());
    try {
      final story = await storyRepository.generateStory();
      emit(StoryLoaded(story: story));
    } catch (e) {
      emit(StoryError(message: e.toString()));
    }
  }
}
