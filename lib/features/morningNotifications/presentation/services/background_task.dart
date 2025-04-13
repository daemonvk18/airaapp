import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String fetchMotivationTask = "fetchMotivationTask";

@pragma('vm:entry-point') // Mandatory for Workmanager callbacks
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchMotivationTask:
        final userId = inputData?['userId'] as String? ?? '';
        final baseUrl = inputData?['baseUrl'] as String? ?? '';

        try {
          final response = await http.get(
            Uri.parse('$baseUrl/api/user/send_motivation?user_id=$userId'),
          );

          if (response.statusCode == 200) {
            final jsonResponse = json.decode(response.body);
            final message = jsonResponse['message'] as String;

            final FlutterLocalNotificationsPlugin notificationsPlugin =
                FlutterLocalNotificationsPlugin();

            // Initialize notifications
            const AndroidInitializationSettings initializationSettingsAndroid =
                AndroidInitializationSettings('@mipmap/ic_launcher');
            const InitializationSettings initializationSettings =
                InitializationSettings(android: initializationSettingsAndroid);
            await notificationsPlugin.initialize(initializationSettings);

            // Show notification
            const androidPlatformChannelSpecifics = AndroidNotificationDetails(
              'daily_motivation_channel',
              'Daily Motivation',
              channelDescription: 'Channel for daily motivation notifications',
              importance: Importance.max,
              priority: Priority.high,
            );
            const platformChannelSpecifics = NotificationDetails(
              android: androidPlatformChannelSpecifics,
            );

            await notificationsPlugin.show(
              0,
              'Daily Motivation',
              message,
              platformChannelSpecifics,
            );
            return true;
          }
        } catch (e) {
          return false;
        }
        return false;
      default:
        return false;
    }
  });
}
