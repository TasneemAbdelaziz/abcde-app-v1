import 'package:flutter/foundation.dart';

import '../../core/models/patient.dart';
import '../../core/models/vital.dart';
import '../../core/repositories/patient_repository.dart';

/// ViewModel for the Home screen.
///
/// Holds everything the Home widget displays: the patient, their vitals, and
/// a short care-journey summary. The widget only reads these â it never does
/// logic or calls the repository itself.
class HomeVm extends ChangeNotifier {
  final PatientRepository _repo;

  HomeVm(this._repo) {
    load(); // mock data is instant, so load straight away
  }

  bool loading = false;
  Patient? patient;
  List<Vital> vitals = [];
  String journeySummary = '';

  Future<void> load() async {
    loading = true;
    notifyListeners();

    patient = _repo.getPatient();
    vitals = _repo.getVitals();
    journeySummary = _repo.getJourneySummary();

    loading = false;
    notifyListeners();
    // TODO: handle errors once the repo can fail.
  }
}
