import 'dart:convert';

import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/features/dailyReminders/data/entities/reminder_entity.dart';
import 'package:airaapp/features/dailyReminders/domain/models/reminder_model.dart';
import 'package:airaapp/features/dailyReminders/domain/repository/remider_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ReminderRepositoryImpl extends ReminderRepository {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  @override
  Future<ReminderEntity> addReminder(
      {required String title, required String scheduledTime}) async {
    final user_id = await secureStorage.read(key: 'user_id_reminder');
    if (user_id == null) {
      throw Exception('User not authenticated');
    }
    try {
      final response =
          await http.post(Uri.parse(ApiConstants.addReminderEndpoint),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'user_id': user_id,
                'title': title,
                'scheduled_time': scheduledTime,
              }));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        return ReminderModel.fromJson(data['reminder']);
      } else {
        throw Exception('Failed to add reminder: ${response.body}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<ReminderEntity>> getReminders() async {
    final user_id = await secureStorage.read(key: 'user_id_reminder');
    if (user_id == null) {
      throw Exception('User not authenticated');
    }
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.getReminderEndpoint}?user_id=${user_id}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reminders = (data['reminders'] as List)
            .map((json) => ReminderModel.fromJson(json))
            .toList();
        return reminders;
      } else {
        throw Exception('Failed to load reminders');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<ReminderEntity> updateReminder(
      {required String reminderId,
      String? title,
      String? scheduledTime,
      String? status}) async {
    final user_id = await secureStorage.read(key: 'user_id_reminder');
    if (user_id == null) {
      throw Exception('User not authenticated');
    }
    try {
      final response =
          await http.post(Uri.parse(ApiConstants.updateReminderEndpoint),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'user_id': user_id,
                'reminder_id': reminderId,
                if (title != null) 'title': title,
                if (scheduledTime != null) 'scheduled_time': scheduledTime,
                if (status != null) 'status': status,
              }));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ReminderModel.fromJson(data['reminder']);
      } else {
        throw Exception('Failed to update reminder: ${response.body}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    final user_id = await secureStorage.read(key: 'user_id_reminder');
    if (user_id == null) {
      throw Exception('User not authenticated');
    }
    try {
      final response = await http.delete(
        Uri.parse(ApiConstants.deleteReminderEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': user_id,
          'reminder_id': reminderId,
        }),
      );
      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
