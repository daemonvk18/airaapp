import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

//intial state
class HomeInitial extends HomeState {}

// State for active bottom navigation tab
class HomeTabChanged extends HomeState {
  final int index;
  HomeTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}

// State for opening chat page
class ChatPageOpened extends HomeState {}
