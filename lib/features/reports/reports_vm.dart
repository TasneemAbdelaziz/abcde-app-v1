import 'package:flutter/foundation.dart';

import '../../core/models/report.dart';
import '../../core/repositories/patient_repository.dart';

/// ViewModel for the Reports screen. Loads the patient's reports.
class ReportsVm extends ChangeNotifier {
  final PatientRepository _repo;

  ReportsVm(this._repo) {
    load(); // mock data is instant, so load straight away
  }

  bool loading = false;
  List<Report> reports = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();

    reports = _repo.getReports();

    loading = false;
    notifyListeners();
    // TODO: handle errors once the repo can fail.
  }
}
