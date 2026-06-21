import 'package:flutter/foundation.dart';

import '../../core/models/diagnosis.dart';
import '../../core/repositories/patient_care_api_repository.dart';

/// ViewModel for the Diagnosis screen.
///
/// Holds the structured [Diagnosis] the screen displays. Now backed by the
/// real API (PatientCareApiRepository), so loading is asynchronous.
class DiagnosisVm extends ChangeNotifier {
  final PatientCareApiRepository _repo;

  // The screen calls load() when it opens (when we're authenticated).
  DiagnosisVm(this._repo);

  bool loading = false;
  String? error;
  Diagnosis? diagnosis;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      diagnosis = await _repo.getDiagnosis();
    } catch (e) {
      error = 'Could not load the diagnosis.';
    }

    loading = false;
    notifyListeners();
  }
}