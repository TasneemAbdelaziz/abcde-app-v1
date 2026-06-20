import 'package:flutter/foundation.dart';

import '../../core/models/visit_stage.dart';
import '../../core/models/patient_visit.dart';
import '../../core/repositories/patient_api_repository.dart';

/// ViewModel for the Journey screen. Loads the treatment stages and lets the
/// patient rate a stage (see RateSheet in core/widgets).
class JourneyVm extends ChangeNotifier {
  final PatientApiRepository _api;

  JourneyVm(this._api);

  bool loading = false;
  List<VisitStage> stages = [];

  /// Loads the visit timeline from `GET /visits/%23{serial}` using the
  /// patient serial discovered by the API (via `GET /auth/me`). The response
  /// contains `data.timeline` which we map to `VisitStage` objects.
  Future<void> load() async {
    loading = true;
    notifyListeners();

    try {
      final serial = await _api.getMySerial();
      if (serial.isEmpty) {
        stages = [];
        return;
      }

      // Fetch the raw timeline array using the repository helper.
      final rawTimeline = await _api.getVisitTimeline(serial);
      // a non-empty entered_at is considered the current one; earlier are done,
      // later ones are upcoming.
      int lastEnteredIndex = -1;
      for (int i = 0; i < rawTimeline.length; i++) {
        final e = rawTimeline[i];
        if ((e['entered_at'] ?? '').toString().isNotEmpty) lastEnteredIndex = i;
      }

      stages = [
        for (int i = 0; i < rawTimeline.length; i++)
          _mapTimelineEntry(rawTimeline[i], i, lastEnteredIndex),
      ];
    } catch (e) {
      stages = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  VisitStage _mapTimelineEntry(
    Map<String, dynamic> e,
    int index,
    int lastEnteredIndex,
  ) {
    final id = (e['id'] ?? '').toString();
    final stageCode = (e['stage'] ?? '').toString();
    final enteredAt = (e['entered_at'] ?? '').toString();
    final decision = (e['decision_note'] ?? '').toString();

    // Title from the canonical prettyStage helper.
    final title = PatientVisit.prettyStage(stageCode);

    // Time string like '08:12' if enteredAt present.
    String time = '';
    if (enteredAt.isNotEmpty) {
      final dt = DateTime.tryParse(enteredAt);
      if (dt != null) {
        time =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    final status = index < lastEnteredIndex
        ? 'done'
        : (index == lastEnteredIndex ? 'current' : 'upcoming');

    return VisitStage(
      id: id,
      title: title,
      status: status,
      rating: 0,
      time: time,
      detail: decision,
    );
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
