import 'package:flutter/foundation.dart';

import '../../core/models/visit_stage.dart';
import '../../core/repositories/patient_repository.dart';

/// ViewModel for the Journey screen. Loads the treatment stages and lets the
/// patient rate a stage (see RateSheet in core/widgets).
class JourneyVm extends ChangeNotifier {
  final PatientRepository _repo;

  JourneyVm(this._repo);

  bool loading = false;
  List<VisitStage> stages = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();

    stages = _repo.getStages();

    loading = false;
    notifyListeners();
    // TODO: handle errors once the repo can fail.
  }

  /// Stores a rating the patient gave to a stage.
  void rateStage(String stageId, int rating) {
    stages = [
      for (final s in stages)
        if (s.id == stageId) s.copyWith(rating: rating) else s,
    ];
    notifyListeners();
    // TODO: persist the rating through the repository when the API exists.
  }
}
