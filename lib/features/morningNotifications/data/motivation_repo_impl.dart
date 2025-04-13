import 'dart:convert';
import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/features/morningNotifications/domain/repository/motivation_repo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MotivationRepositoryImpl implements MotivationRepository {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  @override
  Future<String> getMotivationMessage() async {
    final user_id = await secureStorage.read(key: 'user_id_reminder');
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.sendMotivationEndpoint}?user_id=${user_id}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['message'] as String;
      } else {
        throw Exception('Failed to load motivation message');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
