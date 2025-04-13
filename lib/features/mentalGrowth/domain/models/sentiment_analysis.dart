class SentimentAnalysis {
  final String date;
  final int mentalScore;
  final String emotionalState;
  final String reflectionText;
  final String supportingText;
  final List<String> suggestions;
  final List<KeywordScore> keyWords;

  SentimentAnalysis({
    required this.date,
    required this.mentalScore,
    required this.emotionalState,
    required this.reflectionText,
    required this.supportingText,
    required this.suggestions,
    required this.keyWords,
  });

  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) {
    return SentimentAnalysis(
      date: json['date'] as String,
      mentalScore: json['mental_score'] as int,
      emotionalState: json['emotional_state'] as String,
      reflectionText: json['reflection_text'] as String,
      supportingText: json['supporting_text'] as String,
      suggestions:
          (json['suggestions'] as List).map((e) => e as String).toList(),
      keyWords: (json['key_words'] as List)
          .map((e) => KeywordScore.fromList(e))
          .toList(),
    );
  }
}

class KeywordScore {
  final String keyword;
  final double score;

  KeywordScore({required this.keyword, required this.score});

  factory KeywordScore.fromList(List<dynamic> list) {
    return KeywordScore(
      keyword: list[0] as String,
      score: (list[1] as num).toDouble(),
    );
  }
}
