import 'dart:async';

import 'package:flutter/foundation.dart';

import '../i18n/locale_controller.dart';
import '../models/app_notification.dart';
import '../repositories/patient_api_repository.dart';
import 'local_notifications.dart';
import 'notification_text.dart';

/// Background poller for notifications.
///
/// While the app is running and the user is logged in, this polls
/// `GET /notifications` every [_interval]. It:
///   - keeps a live [unread] count (the Home bell badge watches this), and
///   - fires a system heads-up banner for any notification that newly arrives.
///
/// LIMITATION: this only runs while the app process is alive. True push (banners
/// when the app is closed) needs the backend to support FCM + a device-token
/// endpoint, which the API doesn't expose yet.
class NotificationCenter extends ChangeNotifier {
  final PatientApiRepository _repo;
  final LocaleController _locale;

  NotificationCenter(this._repo, this._locale);

  static const Duration _interval = Duration(seconds: 25);

  Timer? _timer;
  final Set<String> _seen = {};
  bool _primed = false; // first poll done — don't banner pre-existing items

  int unread = 0;
  List<AppNotification> items = [];

  /// Begin polling (call after login). Safe to call more than once.
  void start() {
    if (_timer != null) return;
    _poll();
    _timer = Timer.periodic(_interval, (_) => _poll());
  }

  /// Stop polling and clear state (call on logout).
  void stop() {
    _timer?.cancel();
    _timer = null;
    _seen.clear();
    _primed = false;
    unread = 0;
    items = [];
    notifyListeners();
  }

  /// Force an immediate refresh (e.g. after the user marks items read).
  Future<void> refresh() => _poll();

  Future<void> _poll() async {
    try {
      final page = await _repo.getNotifications();

      final fresh = page.items
          .where((n) => n.id.isNotEmpty && !_seen.contains(n.id))
          .toList();
      for (final n in page.items) {
        if (n.id.isNotEmpty) _seen.add(n.id);
      }

      items = page.items;
      unread = page.unread;

      // Only banner items that arrived after we primed (avoids a burst of
      // banners for everything already on the server at login).
      if (_primed) {
        for (final n in fresh.where((n) => !n.read)) {
          LocalNotifications.show(
            id: n.id.hashCode,
            title: notificationTitle(n, _locale),
            body: n.body,
          );
        }
      }
      _primed = true;
      notifyListeners();
    } catch (_) {
      // Network hiccup — try again next tick.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
