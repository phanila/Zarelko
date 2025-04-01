import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:zarelko/app_extensions.dart';

class NotificationsService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(NotificationResponse notificationResponse) async {

  }

  static Future<void> init({isForeground=true}) async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings("@mipmap/ic_launcher");

    const DarwinInitializationSettings iosInitializationSettings =
    DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings
    );

    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification
    );

    // Permissions should be requested in the foreground or app lifecycle
    if (isForeground) {
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    }
  }

  // Method to check if the app is in the foreground
  static Future<bool> _isForeground() async {
    // You can implement a logic here to check if the app is in the foreground.
    // For example, using a package like `app_lifecycle_state` or checking the app lifecycle state
    // for a more robust approach. For now, you can return true if the app is in the foreground.
    return true; // Placeholder: assume it's in the foreground for simplicity.
  }
  Future<void> showInstantNotification(String title, String body) async {
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails('channel_Id', "channel_Name", importance: Importance.high,priority: Priority.high,styleInformation:  BigTextStyleInformation(body)),
      iOS: const DarwinNotificationDetails()
    );

    await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }
  Future<void> scheduleDelayedNotification(String title, String body, DateTime scheduledTime) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails('channel_Id', "channel_Name", importance: Importance.high,priority: Priority.high),
        iOS: DarwinNotificationDetails()
    );
    print("${DateTime.now().toString()}notification scheduled for ${scheduledTime.toString()}");
    print("${tz.TZDateTime.from(DateTime.now(),tz.local).toString()}what is timed date${tz.TZDateTime.from(scheduledTime, tz.local).toString()}");
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  Future<void> scheduleNotification(String title, String body, DateTime scheduledTime) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails('channel_Id', "channel_Name", importance: Importance.high,priority: Priority.high),
        iOS: DarwinNotificationDetails()
    );
    scheduledTime.zeroTime()
      .add(Duration(hours: 14, minutes: 05));
    await flutterLocalNotificationsPlugin.zonedSchedule(0, title, body, tz.TZDateTime.from(scheduledTime, tz.local),platformChannelSpecifics, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.dateAndTime, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  static Future<void> getScheduledNotifications() async {
    try {
      // Get the list of pending notifications
      List<PendingNotificationRequest> pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();

      // Log or display the pending notifications
      for (var notification in pendingNotifications) {
        print('Pending Notification ID: ${notification.id}');
        print('Title: ${notification.title}');
        print('Body: ${notification.body}');
      }
    } catch (e) {
      print('Error fetching pending notifications: $e');
    }
  }
}