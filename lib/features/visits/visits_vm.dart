import 'package:flutter/foundation.dart';

import '../../core/models/visit.dart';
import '../../core/repositories/patient_care_api_repository.dart';

/// ViewModel for the Visits screen (and the Care Journey it opens).
///
/// Backed by the real API. The `/visits` list does NOT include the timeline,
/// so after loading the list we fetch the Care Journey for the active visit
/// and attach it — that way the Care Journey screen can read it straight out
/// of [visitById] without any extra wiring.
class VisitsVm extends ChangeNotifier {
  final PatientCareApiRepository _repo;

  VisitsVm(this._repo) {
    load();
  }

  bool loading = false;
  String? error;
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
    error = null;
    notifyListeners();

    try {
      final list = await _repo.getVisits();

      // Attach the Care Journey timeline to the active visit.
      final activeIndex = list.indexWhere((v) => v.isActive);
      if (activeIndex != -1) {
        try {
          final journey = await _repo.getJourney();
          list[activeIndex] = list[activeIndex].copyWith(journey: journey);
        } catch (_) {
          // If the journey fails, leave it null — the card still shows.
        }
      }
      visits = list;
    } catch (e) {
      error = 'Could not load visits.';
    }

    loading = false;
    notifyListeners();
  }

  /// Records a stage rating: updates the screen immediately, then sends it to
  /// the backend (POST /stages/{id}/feedback).
  Future<void> rateStage(String visitId, String stageId, int rating) async {
    // Optimistic local update so the stars show right away.
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

    // Send to the backend. Stage ids that came from the timeline are numeric;
    // upcoming stages aren't rateable, so this is safe.
    final id = int.tryParse(stageId);
    if (id != null) {
      try {
        await _repo.rateStage(id, rating);
      } catch (_) {
        // Keep the optimistic update; the rating can be retried later.
      }
    }
  }
}