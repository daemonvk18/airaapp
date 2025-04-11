import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/features/myStory/data/models/story_model.dart';
import 'package:airaapp/features/myStory/domain/entity/story_entity.dart';
import 'package:airaapp/features/myStory/domain/repository/story_repo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoryRepositoryImpl implements StoryRepository {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  @override
  Future<Story> generateStory() async {
    final user_id = await secureStorage.read(key: 'user_id_reminder');
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.getStoryEndpoint}?user_id=${user_id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return StoryModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('failed to fetch the story ${response.body}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
