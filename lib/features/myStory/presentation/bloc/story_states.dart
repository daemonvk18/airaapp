import 'package:airaapp/features/myStory/domain/entity/story_entity.dart';
import 'package:equatable/equatable.dart';

abstract class StoryState extends Equatable {
  @override
  List<Object> get props => [];
}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StoryLoaded extends StoryState {
  final Story story;

  StoryLoaded({required this.story});

  @override
  List<Object> get props => [story];
}

class StoryError extends StoryState {
  final String message;

  StoryError({required this.message});

  @override
  List<Object> get props => [message];
}
