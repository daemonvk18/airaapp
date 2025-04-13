import 'dart:async';
import 'package:airaapp/features/mentalGrowth/domain/repository/sentiment_analysis_repo.dart';
import 'package:airaapp/features/mentalGrowth/presentation/bloc/sentiment_events.dart';
import 'package:airaapp/features/mentalGrowth/presentation/bloc/sentiment_states.dart';
import 'package:bloc/bloc.dart';

class SentimentBloc extends Bloc<SentimentEvent, SentimentState> {
  final SentimentRepository sentimentRepository;

  SentimentBloc({required this.sentimentRepository})
      : super(SentimentInitial()) {
    on<LoadSentiments>(_onLoadSentiments);
  }

  Future<void> _onLoadSentiments(
    LoadSentiments event,
    Emitter<SentimentState> emit,
  ) async {
    emit(SentimentLoading());
    try {
      await sentimentRepository.analyzeSentiment();
      final sentiments = await sentimentRepository.getSentiments();
      emit(SentimentLoaded(sentiments: sentiments));
    } catch (e) {
      emit(SentimentError(message: e.toString()));
    }
  }
}
