import 'dart:convert';

import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/features/mentalGrowth/domain/models/sentiment_analysis.dart';
import 'package:airaapp/features/mentalGrowth/domain/repository/sentiment_analysis_repo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SentimentRepositoryImpl implements SentimentRepository {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  @override
  Future<void> analyzeSentiment() async {
    final user_id = await secureStorage.read(key: 'user_id_reminder');
    if (user_id == null) {
      throw Exception('no user id');
    }
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.getAnalyzeEndpoint}?user_id=${user_id}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
      } else {
        print(jsonDecode(response.body));
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<SentimentAnalysis>> getSentiments() async {
    final user_id = await secureStorage.read(key: 'user_id_reminder');
    if (user_id == null) {
      throw Exception('no user id');
    }
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.getSentimentEndpoint}?user_id=${user_id}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is! Map<String, dynamic> || jsonData['data'] is! List) {
          throw Exception('Invalid API response format');
        }

        final List<dynamic> data = jsonData['data'];

        return data.map((item) {
          if (item is! Map<String, dynamic>) {
            throw Exception('Invalid sentiment data format');
          }

          // Handle potential null values
          final suggestions = item['suggestions'] is List
              ? (item['suggestions'] as List)
                  .map((e) => e?.toString() ?? '')
                  .toList()
              : <String>[];

          final keyWords = item['key_words'] is List
              ? (item['key_words'] as List).whereType<List>().toList()
              : <List>[];

          return SentimentAnalysis.fromJson({
            ...item,
            'suggestions': suggestions,
            'key_words': keyWords,
          });
        }).toList();
      } else {
        print(jsonDecode(response.body));
        throw Exception('Failed to get sentiments');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
