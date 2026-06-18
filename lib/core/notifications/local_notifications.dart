import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Thin wrapper around `flutter_local_notifications` for showing a system
/// heads-up banner when a new notification arrives while the app is running.
///
/// Mobile only — on web (and where the plugin is unavailable) every call is a
/// no-op so the rest of the app keeps working.
class LocalNotifications {
  LocalNotifications._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'alerts';
  static const String _channelName = 'Alerts';

  static bool _ready = false;

  /// Call once at startup. Sets up the channel and asks for permission.
  ///
  /// [onTap] fires when the user taps a notification (its payload is passed
  /// through) so the app can navigate to the right screen.
  static Future<void> init({void Function(String? payload)? onTap}) async {
    if (kIsWeb) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: (resp) => onTap?.call(resp.payload),
      );

      final android13 = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android13?.requestNotificationsPermission();
      await android13?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Care updates and alerts',
          importance: Importance.high,
        ),
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      _ready = true;
    } catch (_) {
      _ready = false; // unsupported platform — stay a no-op
    }
  }

  /// Shows a heads-up notification. No-op if init failed / unsupported.
  /// [payload] is handed back to the `onTap` callback when the user taps it.
  static Future<void> show({
    required int id,
    required String title,
    String body = '',
    String payload = 'notifications',
  }) async {
    if (kIsWeb || !_ready) return;
    try {
      await _plugin.show(
        id,
        title,
        body.isEmpty ? null : body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (_) {
      // Ignore — a failed banner must never crash the app.
    }
  }
}
