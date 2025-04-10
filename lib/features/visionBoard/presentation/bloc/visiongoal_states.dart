import 'package:airaapp/features/visionBoard/domain/entity/goal_entity.dart';
import 'package:equatable/equatable.dart';

abstract class VisionBoardState extends Equatable {
  @override
  List<Object> get props => [];
}

class VisionBoardInitial extends VisionBoardState {}

class VisionBoardLoading extends VisionBoardState {}

class VisionBoardLoaded extends VisionBoardState {
  final List<VisionGoal> goals;

  VisionBoardLoaded(this.goals);

  @override
  List<Object> get props => [goals];
}

class VisionBoardEmpty extends VisionBoardState {}

class VisionBoardError extends VisionBoardState {
  final String message;

  VisionBoardError(this.message);

  @override
  List<Object> get props => [message];
}
