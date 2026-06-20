import '../models/app_notification.dart';
import '../models/patient_profile.dart';
import '../models/patient_visit.dart';
import '../models/vitals_reading.dart';
import '../network/api_client.dart';

/// Talks to the patient-facing backend endpoints used by the Home screen:
///
///   - `GET /auth/me`               → who am I (to discover my patient serial)
///   - `GET /patients/{serial}`     → full profile (age, chronic, care points)
///   - `GET /visits/#{serial}`      → current visit / care-journey stage
///   - `GET /visits/#{serial}/vitals` → vital-sign readings (latest shown)
///   - `GET /notifications`         → `{ unread, items }` (bell badge)
///
/// The visit id is the patient serial prefixed with `#`, URL-encoded as `%23`.
class PatientApiRepository {
  final ApiClient _api;

  PatientApiRepository(this._api);

  /// The signed-in patient's serial (e.g. 'ALM-20416'), or '' if not a patient.
  Future<String> getMySerial() async {
    final res = await _api.getJson('/auth/me');
    final data = res['data'];
    if (data is Map<String, dynamic>) {
      final patient = data['patient'];
      if (patient is Map<String, dynamic>) {
        return (patient['patient_serial'] ?? '').toString();
      }
    }
    return '';
  }

  /// Full profile from `GET /patients/{serial}`.
  Future<PatientProfile> getPatient(String serial) async {
    final res = await _api.getJson('/patients/$serial');
    final data = res['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected profile response.');
    }
    return PatientProfile.fromPatientJson(data);
  }

  /// The patient's current visit, or null if they have none.
  Future<PatientVisit?> getVisit(String serial) async {
    try {
      final res = await _api.getJson('/visits/%23$serial');
      final data = res['data'];
      if (data is Map<String, dynamic>) return PatientVisit.fromJson(data);
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null; // no open visit
      rethrow;
    }
  }

  /// Returns the raw `timeline` array from `GET /visits/#{serial}` as a
  /// list of maps. Returns an empty list if no timeline is present.
  Future<List<Map<String, dynamic>>> getVisitTimeline(String serial) async {
    final res = await _api.getJson('/visits/%23$serial');
    final data = res['data'];
    if (data is Map<String, dynamic> && data['timeline'] is List) {
      return (data['timeline'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  /// The most recent vital-sign reading for the patient's visit, or null.
  Future<VitalsReading?> getLatestVitals(String serial) async {
    try {
      final res = await _api.getJson('/visits/%23$serial/vitals');
      final data = res['data'];
      if (data is List && data.isNotEmpty) {
        final readings = data
            .whereType<Map<String, dynamic>>()
            .map(VitalsReading.fromJson)
            .toList();
        // Latest by taken_at (fall back to list order).
        readings.sort((a, b) {
          final ad = a.takenAt, bd = b.takenAt;
          if (ad == null || bd == null) return 0;
          return ad.compareTo(bd);
        });
        return readings.last;
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Number of unread notifications (for the bell badge). 0 on any problem.
  Future<int> getUnreadCount() async {
    final res = await _api.getJson('/notifications');
    return _unreadOf(res['data']);
  }

  /// Full notifications list + unread count from `GET /notifications`.
  Future<NotificationsPage> getNotifications() async {
    final res = await _api.getJson('/notifications');
    final data = res['data'];
    final items = <AppNotification>[];
    if (data is Map<String, dynamic> && data['items'] is List) {
      for (final e in data['items'] as List) {
        if (e is Map<String, dynamic>) items.add(AppNotification.fromJson(e));
      }
    }
    return NotificationsPage(unread: _unreadOf(data), items: items);
  }

  /// Marks one notification read: `POST /notifications/{id}/read`.
  Future<void> markNotificationRead(String id) async {
    await _api.postJson('/notifications/$id/read', const {});
  }

  int _unreadOf(dynamic data) {
    if (data is Map<String, dynamic>) {
      final unread = data['unread'];
      if (unread is int) return unread;
      return int.tryParse('${unread ?? 0}') ?? 0;
    }
    return 0;
  }
}

/// One page of notifications: the list plus the server's unread count.
class NotificationsPage {
  final int unread;
  final List<AppNotification> items;
  const NotificationsPage({required this.unread, required this.items});
}
