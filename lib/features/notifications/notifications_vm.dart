import 'package:flutter/foundation.dart';

import '../../core/models/app_notification.dart';
import '../../core/network/api_client.dart';
import '../../core/repositories/patient_api_repository.dart';

/// ViewModel for the Notifications screen.
///
/// Loads the list from `GET /notifications` and marks items read via
/// `POST /notifications/{id}/read`. The screen only reads these fields.
class NotificationsVm extends ChangeNotifier {
  final PatientApiRepository _repo;

  NotificationsVm(this._repo);

  bool loading = false;
  String? error;
  int unread = 0;
  List<AppNotification> items = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final page = await _repo.getNotifications();
      unread = page.unread;
      items = page.items;
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Could not load notifications. Pull to refresh.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Marks one notification read. Optimistic: updates the UI immediately and
  /// rolls back if the request fails.
  Future<void> markRead(AppNotification n) async {
    if (n.read || n.id.isEmpty) return;

    final i = items.indexWhere((x) => x.id == n.id);
    if (i < 0) return;

    items[i] = items[i].copyWith(read: true);
    if (unread > 0) unread--;
    notifyListeners();

    try {
      await _repo.markNotificationRead(n.id);
    } catch (_) {
      // Roll back on failure.
      items[i] = items[i].copyWith(read: false);
      unread++;
      notifyListeners();
    }
  }

  /// Marks every unread notification read (loops; there's no bulk endpoint).
  Future<void> markAllRead() async {
    final unreadItems = items.where((n) => !n.read).toList();
    for (final n in unreadItems) {
      await markRead(n);
    }
  }
}
