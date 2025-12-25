import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isinitialized = false;

  bool get isInitialized => _isinitialized;

//Initialize Notification
  Future<void> initNotification() async {
    if (_isinitialized) return;

    //init timezone handling
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );

    await notificationsPlugin.initialize(
      initSettings,
    );

    final androidImplementation =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    final canScheduleExact =
        await androidImplementation?.canScheduleExactNotifications();
    if (canScheduleExact == false) {
      await androidImplementation?.requestExactAlarmsPermission();
    }

    _isinitialized = true;
  }

//Setup Notification Details
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
      ),
    );
  }

  //Show Notification
  Future<void> ShowNotification(
      {int id = 0, String? title, String? body}) async {
    return notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails(),
    );
  }

  Future<void> scheduleNotification({
    int id = 1,
    required String? title,
    required String? body,
    required int hour,
    required int minute,
  }) async {
    //Get Current DateTime
    final now = tz.TZDateTime.now(tz.local);

    //Set Scheduled DateTime
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    //Schedule Notification
    await notificationsPlugin.zonedSchedule(
      id, title, body, scheduledDate, notificationDetails(),

      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      //Make Notification Repeating Daily
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}
