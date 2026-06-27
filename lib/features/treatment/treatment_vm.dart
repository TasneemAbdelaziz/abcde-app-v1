import 'package:flutter/foundation.dart';

import '../../core/models/treatment.dart';
import '../../core/repositories/patient_care_api_repository.dart';

/// ViewModel for the Treatment Plan screen. Loads the plan from the backend:
/// the attending doctor + department, recovery progress derived from the
/// care-journey stage, and today's medicines. Sections the backend has no data
/// for (goals, appointments, adherence) come back empty and the screen hides
/// them. The medicine *list* with photos lives on its own screen (MedicinesVm).
class TreatmentVm extends ChangeNotifier {
  final PatientCareApiRepository _repo;

  TreatmentVm(this._repo) {
    load();
  }

  bool loading = false;
  String? error;
  TreatmentPlan? plan;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      plan = await _repo.getTreatmentPlan();
    } catch (e) {
      error = 'Could not load the treatment plan.';
    }

    loading = false;
    notifyListeners();
  }
}
