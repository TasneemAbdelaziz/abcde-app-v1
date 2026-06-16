import 'package:flutter/foundation.dart';

import '../../core/models/medicine.dart';
import '../../core/repositories/patient_repository.dart';

/// ViewModel for the Treatment screen. Loads the prescribed medicines.
class TreatmentVm extends ChangeNotifier {
  final PatientRepository _repo;

  TreatmentVm(this._repo);

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
