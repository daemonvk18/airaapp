import 'package:airaapp/features/mentalGrowth/domain/models/sentiment_analysis.dart';

abstract class SentimentRepository {
  Future<void> analyzeSentiment();
  Future<List<SentimentAnalysis>> getSentiments();
}
