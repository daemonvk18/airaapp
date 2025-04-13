import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isintialized = false;

  bool get isiniaklized => _isintialized;

  //INTIALIZE IT
  Future<void> initNotifications() async {
    if (_isintialized) return; // prevent re-intialization

    //intialize the timezone
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    //prepare android init settinngs
    const initsettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    //prepare ios init settings
    const initsettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);

    //init setings
    const initSettings = InitializationSettings(
        android: initsettingsAndroid, iOS: initsettingsIOS);

    //finally use them to initialize the plugin!
    await notificationsPlugin.initialize(initSettings);
  }

  //NOTIFICATIONS DETAILS SET UP
  NotificationDetails notificationDetails() {
    return NotificationDetails(
        android: AndroidNotificationDetails(
            'daily_channel_id', 'Daily_Notifications',
            channelDescription: 'Daily Notification Channel',
            importance: Importance.max,
            priority: Priority.high),
        iOS: DarwinNotificationDetails());
  }

  //SHOW NOTIFICATIONS
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  /*
Scheduling a Notification at a specific time and date
- hour(0-23)
-minute(0-59)
  */
  //this notification is for reminders
  Future<void> scheduleNotifications(
      {int id = 1,
      required String title,
      required String body,
      required int year,
      required int month,
      required int day,
      required int hour,
      required int minute}) async {
    //get the current date time in the device localZone
    // ignore: unused_local_variable
    final now = tz.TZDateTime.now(tz.local);
    //create a datetime today at the specified hour/minute
    var scheduledDate = tz.TZDateTime(tz.local, year, month, day, hour, minute);

    //schedule the actual notification
    await notificationsPlugin.zonedSchedule(
      id, title, body, scheduledDate, notificationDetails(),
      //ios specific stuff...
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      //android specific stuff...(allow notifications in low-power mode as well)
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      //we can also make sure that the notifications appear dialy at the same time
      // matchDateTimeComponents: DateTimeComponents.time
    );
  }

  //write schedule notification functions for morning sending notification
  Future<void> scheduleMorningnotifications(
      {int id = 2,
      required String title,
      required String body,
      required int hour,
      required int minute}) async {
    final now = tz.TZDateTime.now(tz.local);
    //create a datetime today at the specified hour/minute
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    //schedule the actual notification
    await notificationsPlugin.zonedSchedule(
        id, title, body, scheduledDate, notificationDetails(),
        //ios specific stuff...
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        //android specific stuff...(allow notifications in low-power mode as well)
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        //we can also make sure that the notifications appear dialy at the same time
        matchDateTimeComponents: DateTimeComponents.time);
  }

  //cancel all the notifications
  Future<void> cancelNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}
