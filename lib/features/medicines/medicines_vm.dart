import 'package:flutter/foundation.dart';

import '../../core/models/medicine.dart';
import '../../core/repositories/patient_care_api_repository.dart';

/// ViewModel for the Medicines screen. Loads the prescribed medicines from the
/// real API (PatientCareApiRepository).
class MedicinesVm extends ChangeNotifier {
  final PatientCareApiRepository _repo;

  MedicinesVm(this._repo) {
    load();
  }

  bool loading = false;
  String? error;
  List<Medicine> medicines = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      medicines = await _repo.getMedicines();
    } catch (e) {
      error = 'Could not load medicines.';
    }

    loading = false;
    notifyListeners();
  }
}