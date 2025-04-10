import 'package:equatable/equatable.dart';

abstract class VisionBoardEvent extends Equatable {
  @override
  // ignore: override_on_non_overriding_member
  List<Object> get props => [];
}

class LoadVisionGoals extends VisionBoardEvent {}

class AddVisionGoal extends VisionBoardEvent {
  final String goal;

  AddVisionGoal(this.goal);

  @override
  List<Object> get props => [goal];
}
