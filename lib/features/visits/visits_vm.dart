import 'package:flutter/foundation.dart';

import '../../core/models/visit.dart';
import '../../core/repositories/patient_repository.dart';

/// ViewModel for the Visits screen (and the Care Journey it opens).
///
/// Holds the list of visits. The Care Journey screen reads the active visit
/// back out of here by id, so a rating submitted there updates this list and
/// both screens stay in sync.
class VisitsVm extends ChangeNotifier {
  final PatientRepository _repo;

  VisitsVm(this._repo) {
    load(); // mock data is instant, so load straight away
  }

  bool loading = false;
  List<Visit> visits = [];

  /// Looks up a visit by id (used by the Care Journey screen).
  Visit? visitById(String id) {
    for (final v in visits) {
      if (v.id == id) return v;
    }
    return null;
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();

    visits = _repo.getVisits();

    loading = false;
    notifyListeners();
    // TODO: handle errors once the repo can fail.
  }

  /// Stores a rating the patient gave to a stage of a visit's Care Journey.
  void rateStage(String visitId, String stageId, int rating) {
    visits = [
      for (final v in visits)
        if (v.id == visitId && v.journey != null)
          v.copyWith(
            journey: v.journey!.copyWith(
              stages: [
                for (final s in v.journey!.stages)
                  if (s.id == stageId) s.copyWith(rating: rating) else s,
              ],
            ),
          )
        else
          v,
    ];
    notifyListeners();
    // TODO: persist the rating through the repository when the API exists.
  }
}