import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._private();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService._private();

  factory NotificationService() {
    return _instance;
  }

  Future<void> initNotificationPlugin({
    required Function(String? payload) onNotificationTap,
    required Function(NotificationResponse response) onBackgroundNotificationTap
  }) async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('notification_icon');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationTap(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
    );

    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();
  }

  Future<void> scheduleNotification(
      int id,
      String title,
      String body,
      DateTime scheduledTime,
      String payload,
  ) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          channelDescription: 'channel_description',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload
    );
  }

  Future<void> cancelNotificationById(int id) async {
    await _notificationsPlugin.cancel(id);
    print('Notification with ID: $id canceled');
  }

  Future<void> cancelNotificationsByPayload(String payload) async {
    final List<PendingNotificationRequest> pendingNotifications = await getPendingNotifications();
    final payloadForCanceling = jsonDecode(payload);

    for (final notification in pendingNotifications) {
      final notificationPayload = jsonDecode(notification.payload!);
      if (notificationPayload['id'] == payloadForCanceling['id']) {
        _notificationsPlugin.cancel(notification.id);
        print("Notification with ID: ${notification.id} canceled");
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    print('All notifications canceled');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications = await _notificationsPlugin.pendingNotificationRequests();
    return pendingNotifications;
  }

   Future<void> showTestNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.max,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }
}
