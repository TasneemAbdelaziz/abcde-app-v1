import 'package:flutter/foundation.dart';

import '../../core/models/financial_file.dart';
import '../../core/models/report.dart';
import '../../core/repositories/patient_api_repository.dart';
import '../../core/repositories/patient_repository.dart';
import '../home/home_vm.dart';

/// ViewModel for the Reports screen. Loads the patient's reports.
class ReportsVm extends ChangeNotifier {
  final PatientRepository _repo;
  final PatientApiRepository _api;
  final HomeVm _home;

  ReportsVm(this._repo, this._api, this._home) {
    _home.addListener(_homeListener);
    load();
  }

  bool loading = false;
  bool financialLoading = false;
  List<Report> reports = [];
  FinancialFile? financialFile;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    reports = _repo.getReports();
    await _loadFinancialFile();

    loading = false;
    notifyListeners();
  }

  Future<void> _loadFinancialFile() async {
    if (_home.profile == null) {
      return;
    }

    financialLoading = true;
    notifyListeners();
    try {
      financialFile = await _api.getFinancialFile(_home.profile!.serial);
    } catch (_) {
      financialFile = null;
    } finally {
      financialLoading = false;
      notifyListeners();
    }
  }

  void _homeListener() {
    if (_home.profile != null) {
      _home.removeListener(_homeListener);
      _loadFinancialFile();
    }
  }

  @override
  void dispose() {
    _home.removeListener(_homeListener);
    super.dispose();
  }
}
