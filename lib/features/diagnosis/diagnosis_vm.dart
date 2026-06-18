import 'package:flutter/foundation.dart';

import '../../core/models/diagnosis.dart';
import '../../core/repositories/patient_repository.dart';

/// ViewModel for the Diagnosis screen.
///
/// Holds the structured [Diagnosis] the screen displays: the headline
/// condition, the explainer video, the plain-language summary, and the
/// prevention videos. The widget only reads this — it never calls the
/// repository itself.
class DiagnosisVm extends ChangeNotifier {
  final PatientRepository _repo;

  DiagnosisVm(this._repo) {
    load(); // mock data is instant, so load straight away
  }

  bool loading = false;
  Diagnosis? diagnosis;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    diagnosis = _repo.getDiagnosis();

    loading = false;
    notifyListeners();
    // TODO: handle errors once the repo can fail.
  }
}