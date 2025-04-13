import 'package:airaapp/features/mentalGrowth/domain/models/sentiment_analysis.dart';
import 'package:equatable/equatable.dart';

abstract class SentimentState extends Equatable {
  @override
  List<Object> get props => [];
}

class SentimentInitial extends SentimentState {}

class SentimentLoading extends SentimentState {}

class SentimentLoaded extends SentimentState {
  final List<SentimentAnalysis> sentiments;

  SentimentLoaded({required this.sentiments});

  @override
  List<Object> get props => [sentiments];
}

class SentimentError extends SentimentState {
  final String message;

  SentimentError({required this.message});

  @override
  List<Object> get props => [message];
}
