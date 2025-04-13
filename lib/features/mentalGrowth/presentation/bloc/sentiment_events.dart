import 'package:equatable/equatable.dart';

abstract class SentimentEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadSentiments extends SentimentEvent {
  LoadSentiments();

  @override
  List<Object> get props => [];
}
