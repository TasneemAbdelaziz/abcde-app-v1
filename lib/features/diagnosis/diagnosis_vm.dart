import 'package:flutter/foundation.dart';

import '../../core/repositories/patient_repository.dart';

/// ViewModel for the Diagnosis screen. Loads the diagnosis findings.
class DiagnosisVm extends ChangeNotifier {
  final PatientRepository _repo;

  DiagnosisVm(this._repo);

  bool loading = false;
  List<String> findings = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();

    findings = _repo.getDiagnosis();

    loading = false;
    notifyListeners();
    // TODO: handle errors once the repo can fail.
  }
}
