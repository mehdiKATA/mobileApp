import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize notifications (Android + iOS)
  static Future<void> init() async {
    // ANDROID
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS
    const DarwinInitializationSettings iosInit =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notifications.initialize(settings);
  }

  /// Show notification (Android + iOS)
  static Future<void> show({
    required String notificationTitle,
    required String notificationBody,
  }) async {
    // ANDROID
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'lost_item_channel', // channel id
      'Lost Item Notifications', // channel name
      channelDescription: 'Notification after submitting lost item',
      importance: Importance.max,
      priority: Priority.high,
    );

    // iOS
    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      notificationTitle,
      notificationBody,
      details,
    );
  }
}
