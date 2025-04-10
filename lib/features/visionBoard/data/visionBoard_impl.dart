import 'dart:convert';
import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/features/visionBoard/data/models/goal_model.dart';
import 'package:airaapp/features/visionBoard/domain/Repository/vision_board_repo.dart';
import 'package:airaapp/features/visionBoard/domain/entity/goal_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class VisionBoardImpl implements VisionBoardRepo {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  @override
  Future<VisionGoal> adddreams(String goal) async {
    final user_id = await secureStorage.read(key: 'user_id_reminder');
    try {
      final response = await http.post(
          Uri.parse(ApiConstants.addDreamsEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': user_id, 'goal': goal}));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return VisionGoal(
          id: data['id'] ?? '',
          text: data['text'] ?? '', // Changed from 'goal' to 'text'
          timestamp: data['timestamp']?.toString() ?? '',
        );
      } else {
        throw Exception(response.body.toString());
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<VisionGoal>> getdreams() async {
    final user_id = await secureStorage.read(key: 'user_id_reminder');
    if (user_id == null) {
      throw Exception('user not autheticated');
    }
    try {
      final response = await http.get(
          Uri.parse('${ApiConstants.getDreamsEndpoint}?user_id=${user_id}'),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final List<dynamic> goalsJson = decodedResponse['goals'] ?? [];
        return goalsJson.map((json) => VisionGoalModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
