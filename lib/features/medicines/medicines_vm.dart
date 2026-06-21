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

  bool _disposed = false;
  bool loading = false;
  String? error;
  List<Medicine> medicines = [];

  Future<void> load() async {
    loading = true;
    error = null;
    _notify();

    try {
      medicines = await _repo.getMedicines();
    } catch (e) {
      error = 'Could not load medicines.';
    } finally {
      loading = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}