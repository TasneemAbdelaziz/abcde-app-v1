import 'package:flutter/foundation.dart';

import '../../core/repositories/patient_repository.dart';

/// ViewModel for the Visits screen. Loads past/upcoming visits.
class VisitsVm extends ChangeNotifier {
  final PatientRepository _repo;

  VisitsVm(this._repo);

  bool loading = false;
  List<String> visits = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();

    visits = _repo.getVisits();

    loading = false;
    notifyListeners();
    // TODO: handle errors once the repo can fail.
  }
}
