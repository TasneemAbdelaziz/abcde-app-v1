 import 'package:flutter/foundation.dart';

import '../../core/models/patient_profile.dart';
import '../../core/models/patient_visit.dart';
import '../../core/models/vital.dart';
import '../../core/models/vitals_reading.dart';
import '../../core/network/api_client.dart';
import '../../core/repositories/patient_api_repository.dart';

/// ViewModel for the Home screen.
///
/// Loads everything the design needs straight from the backend:
///   - profile      → `GET /patients/{serial}`         (name, age, gender, …)
///   - visit        → `GET /visits/#{serial}`          (care-journey stage,
///                                                       admission, room, doctor)
///   - latestVitals → `GET /visits/#{serial}/vitals`   (heart rate, SpO₂, …)
///   - unread       → `GET /notifications`             (bell badge)
///
/// Only the "Est. discharge" date has no backend field yet, so that single chip
/// shows the visit status instead.
class HomeVm extends ChangeNotifier {
  final PatientApiRepository _repo;

  // NOTE: we do NOT load() in the constructor. The provider may build this VM
  // before login (so there'd be no auth token yet → "Unauthenticated"). The
  // Home screen calls load() when it appears, by which point we're signed in.
  HomeVm(this._repo);

  bool loading = false;
  String? error;

  PatientProfile? profile;
  PatientVisit? visit;
  VitalsReading? latestVitals;
  int unreadNotifications = 0;

  /// The vital-sign strip. Empty until [latestVitals] arrives.
  List<Vital> get vitals => latestVitals?.toVitals() ?? const [];
  bool get hasVitals => latestVitals != null;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final serial = await _repo.getMySerial();
      if (serial.isEmpty) {
        // Signed in but not a patient (e.g. a doctor account).
        error = 'No patient record for this account.';
        return;
      }

      profile = await _repo.getPatient(serial);
      // Visit + vitals are optional: a patient may have no open visit.
      visit = await _safe<PatientVisit?>(() => _repo.getVisit(serial));
      latestVitals =
          await _safe<VitalsReading?>(() => _repo.getLatestVitals(serial));
      unreadNotifications =
          await _safe<int>(() => _repo.getUnreadCount()) ?? 0;
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Could not load your data. Pull to refresh.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Runs [action], swallowing errors to null so one optional call can't blank
  /// the whole page.
  Future<T?> _safe<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      return null;
    }
  }
}
