import '../models/app_notification.dart';
import '../models/financial_file.dart';
import '../models/patient_profile.dart';
import '../models/patient_visit.dart';
import '../models/report.dart';
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

  /// Fetches the patient's family members from `GET /patients/{serial}/family`.
  /// Returns the raw list of maps (empty list on missing data).
  Future<List<Map<String, dynamic>>> getFamily(String serial) async {
    final res = await _api.getJson('/patients/$serial/family');
    final data = res['data'];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    return <Map<String, dynamic>>[];
  }

  /// Adds a family member / caregiver: `POST /patients/{serial}/family`.
  Future<void> addFamilyMember(
    String serial,
    Map<String, dynamic> body,
  ) async {
    if (serial.isEmpty) return;
    await _api.postJson('/patients/$serial/family', body);
  }

  /// Removes a family member: `DELETE /family/{id}`.
  Future<void> deleteFamilyMember(String id) async {
    if (id.isEmpty) return;
    await _api.deleteJson('/family/$id');
  }

  /// Gets the current visit financial file for the patient.
  Future<FinancialFile?> getFinancialFile(String serial) async {
    try {
      final res = await _api.getJson('/visits/%23$serial/financial-file');
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        return FinancialFile.fromJson(data);
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
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

  /// Lab + radiology results for the patient's visit, mapped to [Report]s.
  /// `GET /visits/#{serial}/results`. Empty list if there's no open visit.
  Future<List<Report>> getResults(String serial) async {
    if (serial.isEmpty) return const [];
    try {
      final res = await _api.getJson('/visits/%23$serial/results');
      final data = res['data'];
      final out = <Report>[];
      if (data is Map<String, dynamic>) {
        for (final e in (data['lab_results'] as List? ?? const [])) {
          if (e is Map<String, dynamic>) out.add(_labReport(e));
        }
        for (final e in (data['radiology_results'] as List? ?? const [])) {
          if (e is Map<String, dynamic>) out.add(_radiologyReport(e));
        }
      }
      return out;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const [];
      rethrow;
    }
  }

  Report _labReport(Map<String, dynamic> j) {
    final value = (j['result_value'] ?? '').toString();
    final unit = (j['unit'] ?? '').toString();
    final flag = (j['flag'] ?? '').toString().toUpperCase();
    final flagLabel = flag == 'H'
        ? ' · High'
        : flag == 'L'
            ? ' · Low'
            : '';
    return Report(
      id: 'lab-${j['id']}',
      title: (j['test_name'] ?? 'Lab test').toString(),
      subtitle: '$value $unit$flagLabel'.trim(),
      date: (j['resulted_at'] ?? j['ordered_at'] ?? '').toString(),
      type: 'lab',
    );
  }

  Report _radiologyReport(Map<String, dynamic> j) {
    return Report(
      id: 'rad-${j['id']}',
      title: (j['study'] ?? 'Imaging study').toString(),
      subtitle: (j['report_summary'] ?? '').toString(),
      date: (j['resulted_at'] ?? j['ordered_at'] ?? '').toString(),
      type: 'imaging',
    );
  }

  /// Saves the patient's preferred language to the backend:
  /// `PUT /patients/{serial}/preferences` with `{ preferred_language }`.
  Future<void> setPreferredLanguage(String serial, String code) async {
    if (serial.isEmpty) return;
    await _api.putJson('/patients/$serial/preferences', {
      'preferred_language': code,
    });
  }

  /// Submits a star rating for a care-journey stage:
  /// `POST /stages/{id}/feedback` with `{ stars, comment }`.
  Future<void> rateStage(String stageId, int stars, {String comment = ''}) async {
    await _api.postJson('/stages/$stageId/feedback', {
      'stars': stars,
      if (comment.isNotEmpty) 'comment': comment,
    });
  }

  /// Submits a patient improvement suggestion: `POST /suggestions`.
  /// [area] must be one of the backend enums (patient_services, facilities,
  /// staff, waiting_time, app_tech, other). The patient is resolved from the
  /// bearer token, so no serial is sent.
  Future<void> submitSuggestion({
    required String area,
    required String suggestionText,
    String? ticketNo,
  }) async {
    await _api.postJson('/suggestions', {
      'area': area,
      'suggestion_text': suggestionText,
      if (ticketNo != null && ticketNo.isNotEmpty) 'ticket_no': ticketNo,
    });
  }

  /// Reads the patient's current overall-care rating: `GET /ratings/overall`.
  /// Returns null when the patient hasn't rated yet (`data: null`).
  Future<OverallRating?> getOverallRating() async {
    try {
      final res = await _api.getJson('/ratings/overall');
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        final stars = int.tryParse('${data['stars'] ?? 0}') ?? 0;
        if (stars <= 0) return null;
        return OverallRating(
          stars: stars,
          comment: (data['comment'] ?? '').toString(),
        );
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Submits / updates the patient's overall-care rating:
  /// `POST /ratings/overall` with `{ stars, comment, ticket_no }`. The backend
  /// upserts (one rating per patient), so re-submitting edits the existing one.
  Future<void> submitOverallRating({
    required int stars,
    String comment = '',
    String? ticketNo,
  }) async {
    await _api.postJson('/ratings/overall', {
      'stars': stars,
      if (comment.isNotEmpty) 'comment': comment,
      if (ticketNo != null && ticketNo.isNotEmpty) 'ticket_no': ticketNo,
    });
  }

  /// Updates a family member's permissions:
  /// `PATCH /family/{id}/permissions` with the six boolean flags.
  Future<void> updateFamilyPermissions(
    String id,
    Map<String, dynamic> permissions,
  ) async {
    if (id.isEmpty) return;
    await _api.patchJson('/family/$id/permissions', permissions);
  }

  /// Translates arbitrary free text via `POST /documentation/translate`.
  /// Returns the translated text, or the original text on any problem.
  Future<String> translateText(String text, String target) async {
    if (text.isEmpty) return text;
    try {
      final res = await _api.postJson('/documentation/translate', {
        'text': text,
        'target': target,
      });
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        final translated = (data['translated_text'] ?? '').toString();
        if (translated.isNotEmpty) return translated;
      }
      return text;
    } on ApiException {
      return text;
    }
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

/// The patient's overall-care rating (1–5 stars + optional comment).
class OverallRating {
  final int stars;
  final String comment;
  const OverallRating({required this.stars, required this.comment});
}
