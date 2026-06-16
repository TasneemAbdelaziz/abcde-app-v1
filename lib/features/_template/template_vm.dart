import 'package:flutter/foundation.dart';

import '../../core/repositories/patient_repository.dart';

/// Example ViewModel: a ChangeNotifier that loads data from the repository.
///
/// A ViewModel holds state + logic for ONE screen. The screen reads it with
/// `context.watch<TemplateVm>()` and only displays what it finds here.
class TemplateVm extends ChangeNotifier {
  final PatientRepository _repo;

  TemplateVm(this._repo);

  bool loading = false;
  List<String> items = [];

  /// Loads data, flipping [loading] so the screen can show a spinner.
  Future<void> load() async {
    loading = true;
    notifyListeners();

    // Call a repository method here. (Using getVisits just as an example.)
    items = _repo.getVisits();

    loading = false;
    notifyListeners();
    // TODO: handle errors (try/catch) once the repo can fail.
  }
}
