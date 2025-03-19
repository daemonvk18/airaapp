import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event to change bottom navigation tab
class ChangeTab extends HomeEvent {
  final int index;
  ChangeTab(this.index);

  @override
  List<Object?> get props => [index];
}

//new homereset event to get back to the homereset
class ResetHomeState extends HomeEvent {}

// Event to navigate to chat page
class NavigateToChat extends HomeEvent {}
