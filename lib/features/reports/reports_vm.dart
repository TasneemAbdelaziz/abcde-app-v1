import 'package:flutter/foundation.dart';

import '../../core/models/financial_file.dart';
import '../../core/models/report.dart';
import '../../core/repositories/patient_api_repository.dart';
import '../home/home_vm.dart';

/// ViewModel for the Reports screen. Loads the patient's reports.
class ReportsVm extends ChangeNotifier {
  final PatientApiRepository _api;
  final HomeVm _home;

  ReportsVm(this._api, this._home) {
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

    await _loadReports();
    await _loadFinancialFile();

    loading = false;
    notifyListeners();
  }

  /// Lab + radiology results from `GET /visits/#{serial}/results`.
  Future<void> _loadReports() async {
    final serial = _home.profile?.serial ?? '';
    if (serial.isEmpty) return; // wait for the home profile (see _homeListener)
    try {
      reports = await _api.getResults(serial);
    } catch (_) {
      reports = [];
    }
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
      _loadReports().then((_) {
        notifyListeners();
        _loadFinancialFile();
      });
    }
  }

  @override
  void dispose() {
    _home.removeListener(_homeListener);
    super.dispose();
  }
}
