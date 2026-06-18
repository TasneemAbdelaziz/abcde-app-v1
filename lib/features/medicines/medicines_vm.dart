import 'package:flutter/foundation.dart';

import '../../core/models/medicine.dart';
import '../../core/repositories/patient_repository.dart';

/// ViewModel for the Medicines screen. Loads the prescribed medicines.
class MedicinesVm extends ChangeNotifier {
  final PatientRepository _repo;

  MedicinesVm(this._repo) {
    load(); // mock data is instant, so load straight away
  }

  bool loading = false;
  List<Medicine> medicines = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();

    medicines = _repo.getMedicines();

    loading = false;
    notifyListeners();
    // TODO: handle errors once the repo can fail.
  }
}