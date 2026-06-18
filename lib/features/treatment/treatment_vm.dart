import 'package:flutter/foundation.dart';

import '../../core/models/treatment.dart';
import '../../core/repositories/patient_repository.dart';

/// ViewModel for the Treatment Plan screen. Loads the full plan: recovery
/// progress, explainer videos, today's medicine timeline, goals, and upcoming
/// appointments. The medicine *list* (with photos) lives on its own screen and
/// uses MedicinesVm.
class TreatmentVm extends ChangeNotifier {
  final PatientRepository _repo;

  TreatmentVm(this._repo) {
    load(); // mock data is instant, so load straight away
  }

  bool loading = false;
  TreatmentPlan? plan;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    plan = _repo.getTreatment();

    loading = false;
    notifyListeners();
    // TODO: handle errors once the repo can fail.
  }
}