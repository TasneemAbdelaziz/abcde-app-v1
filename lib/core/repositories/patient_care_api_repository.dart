import '../models/diagnosis.dart';
import '../models/medicine.dart';
import '../models/treatment.dart';
import '../models/visit.dart';
import '../models/visit_stage.dart';
import '../network/api_client.dart';

/// Backend data for the Diagnosis, Visits / Care Journey, Treatment and
/// Medicines screens.
///
/// Plugs into the SHARED [ApiClient] (the same one AuthRepository logs in), so
/// the bearer token is already attached — no second client, no `dio`.
///
/// Most patient screens are about ONE visit, whose id is the patient serial
/// prefixed with `#` (URL-encoded `%23`). The serial is discovered once from
/// `GET /auth/me` and cached.
class PatientCareApiRepository {
  final ApiClient _api;

  PatientCareApiRepository(this._api);

  String? _cachedSerial;

  /// The signed-in patient's serial (e.g. 'ALM-20413'), discovered + cached.
  Future<String> _serial() async {
    if (_cachedSerial != null && _cachedSerial!.isNotEmpty) return _cachedSerial!;
    final res = await _api.getJson('/auth/me');
    final data = res['data'];
    if (data is Map<String, dynamic>) {
      final patient = data['patient'];
      if (patient is Map<String, dynamic>) {
        _cachedSerial = (patient['patient_serial'] ?? '').toString();
      }
    }
    return _cachedSerial ?? '';
  }

  Future<Map<String, dynamic>> _visitDetail() async {
    final serial = await _serial();
    final res = await _api.getJson('/visits/%23$serial');
    final data = res['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected visit response.');
    }
    return data;
  }

  /// GET /visits — the "My Visits" list.
  Future<List<Visit>> getVisits() async {
    final res = await _api.getJson('/visits');
    final data = res['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(_visitFromApi)
        .toList();
  }

  /// Diagnosis screen (from the visit-detail object).
  Future<Diagnosis> getDiagnosis() async => _diagnosisFromVisit(await _visitDetail());

  /// Translates free text on demand via `POST /documentation/translate`.
  /// Returns the translated text, or the original text on any problem (so the
  /// UI always shows something readable). [target] is a locale code: ar|ru|zh|en.
  Future<String> translateText(String text, String target) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;
    try {
      final res = await _api.postJson('/documentation/translate', {
        'text': trimmed,
        'target': target,
      });
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        final translated = (data['translated_text'] ?? '').toString();
        if (translated.isNotEmpty) return translated;
      }
      return text;
    } on ApiException {
      return text;
    }
  }

  /// Care Journey timeline (from the visit-detail object).
  Future<VisitJourney> getJourney() async => _journeyFromVisit(await _visitDetail());

  /// GET /visits/{id}/prescriptions — the My Medicines list.
  Future<List<Medicine>> getMedicines() async {
    final serial = await _serial();
    final res = await _api.getJson('/visits/%23$serial/prescriptions');
    final data = res['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(_medicineFromApi)
        .toList();
  }

  /// POST /stages/{id}/feedback — submit a Care-Journey stage rating.
  Future<void> rateStage(int stageId, int stars, {String comment = ''}) async {
    await _api.postJson('/stages/$stageId/feedback', {
      'stars': stars,
      'comment': comment,
    });
  }

  /// Treatment Plan, assembled from the data the backend actually exposes:
  /// the attending doctor + department (visit detail), recovery progress
  /// derived from the care-journey stage, and today's medicines (prescriptions).
  ///
  /// Fields the backend has no endpoint for yet — adherence %, daily goals,
  /// upcoming appointments, per-dose taken/due status — are left empty so the
  /// screen can hide those sections instead of showing placeholder data. The
  /// two explainer videos stay local assets.
  Future<TreatmentPlan> getTreatmentPlan() async {
    final d = await _visitDetail();
    final doctor = _m(d['doctor']);
    final dept = _m(d['department']);
    final doctorName = (doctor['full_name'] as String?) ?? '';
    final deptName = (dept['department_name'] as String?) ?? '';

    // Recovery progress derived from how far along the care-journey stage is.
    final currentStage = (d['current_stage'] as String?) ?? '';
    final total = _stageOrder.length;
    final idx = _stageOrder.indexOf(currentStage);
    final done = idx >= 0 ? idx : 0; // stages before the current one are complete
    final recoveryPercent = total == 0 ? 0 : ((done / total) * 100).round();

    // Today's medicines from the prescriptions list. The backend doesn't give
    // per-dose times/status, so we show the drug + frequency without a schedule.
    final timeline = <MedicineDose>[];
    try {
      final serial = await _serial();
      final pres = await _api.getJson('/visits/%23$serial/prescriptions');
      for (final e in _l(pres['data']).whereType<Map<String, dynamic>>()) {
        final drug = (e['drug_name'] as String?) ?? '';
        final dose = (e['dose'] as String?) ?? '';
        timeline.add(MedicineDose(
          time: '',
          period: '',
          name: '$drug $dose'.trim(),
          note: _sentence((e['frequency'] as String?) ?? ''),
          status: DoseStatus.upcoming,
        ));
      }
    } catch (_) {
      // No prescriptions / transient error — leave the timeline empty.
    }

    final mock = TreatmentPlan.fromMock(); // local explainer videos only

    return TreatmentPlan(
      doctorName: doctorName,
      doctorInitials: _initials(doctorName),
      doctorMeta: deptName,
      recoveryPercent: recoveryPercent,
      tasksCompleted: done,
      tasksTotal: total,
      nextDose: '',
      toDischarge: '',
      adherencePercent: 0,
      surgeryVideo: mock.surgeryVideo,
      afterSurgeryVideo: mock.afterSurgeryVideo,
      timeline: timeline,
      goals: const [],
      upcoming: const [],
    );
  }
}

// ===========================================================================
// Mappers (API JSON -> app models)
// ===========================================================================

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
String _two(int n) => n.toString().padLeft(2, '0');

DateTime? _parse(String? s) =>
    (s == null || s.isEmpty) ? null : DateTime.tryParse(s.replaceFirst(' ', 'T'));

String _dateLabel(String? s) {
  final d = _parse(s);
  if (d == null) return '';
  return '${_months[d.month - 1]} ${d.day}, ${d.year} \u00b7 ${_two(d.hour)}:${_two(d.minute)}';
}

String _timeLabel(String? s) {
  final d = _parse(s);
  return d == null ? '' : '${_two(d.hour)}:${_two(d.minute)}';
}

String _initials(String name) {
  final parts = name
      .split(' ')
      .where((p) => p.isNotEmpty && !p.toLowerCase().startsWith('dr'))
      .toList();
  if (parts.isEmpty) return '?';
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}

String _sentence(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

const List<String> _stageOrder = [
  'arrival', 'triage', 'diagnosis', 'cathprep',
  'cath', 'recovery', 'ward', 'discharge',
];
const Map<String, String> _stageNames = {
  'arrival': 'Arrival & Registration',
  'triage': 'Triage Assessment',
  'diagnosis': 'Diagnosis',
  'cathprep': 'Catheterization Prep',
  'cath': 'Catheterization',
  'recovery': 'Recovery & Monitoring',
  'ward': 'Ward Admission',
  'discharge': 'Discharge',
};

Map<String, dynamic> _m(dynamic v) =>
    (v is Map) ? v.cast<String, dynamic>() : <String, dynamic>{};
List _l(dynamic v) => (v is List) ? v : const [];

Visit _visitFromApi(Map<String, dynamic> j) {
  final doctor = _m(j['doctor']);
  final dept = _m(j['department']);
  final name = (doctor['full_name'] as String?) ?? '';
  final idx = _stageOrder.indexOf((j['current_stage'] as String?) ?? '');
  final open = j['visit_status'] == 'open';
  return Visit(
    id: (j['ticket_no'] as String?) ?? '',
    status: open ? VisitStatus.active : VisitStatus.completed,
    title: (dept['department_name'] as String?) ?? 'Hospital visit',
    doctorName: name,
    doctorInitials: _initials(name),
    department: (dept['department_name'] as String?) ?? (j['dept_code'] as String?) ?? '',
    dateLabel: _dateLabel(j['arrived_at'] as String?),
    currentStage: idx >= 0 ? idx + 1 : 0,
    totalStages: _stageOrder.length,
    progressLabel: open ? 'in progress' : 'completed',
    rating: 0,
    journey: null,
  );
}

Diagnosis _diagnosisFromVisit(Map<String, dynamic> d) {
  final list = _l(d['diagnoses']);
  final primary = _m(list.firstWhere(
    (x) => _m(x)['is_primary'] == true,
    orElse: () => list.isNotEmpty ? list.first : {},
  ));
  final doctor = _m(d['doctor']);
  final dept = _m(d['department']);
  final mock = Diagnosis.fromMock(); // local videos + explanation until /education/videos
  return Diagnosis(
    condition: (primary['diagnosis'] as String?) ?? 'Diagnosis',
    department: (dept['department_name'] as String?) ?? '',
    doctor: (doctor['full_name'] as String?) ?? '',
    admitted: 'Admitted ${_dateLabel(d['arrived_at'] as String?)}',
    explanation: mock.explanation,
    caseVideo: mock.caseVideo,
    preventionVideos: mock.preventionVideos,
  );
}

VisitJourney _journeyFromVisit(Map<String, dynamic> d) {
  final patient = _m(d['patient']);
  final list = _l(d['diagnoses']);
  final primary = _m(list.firstWhere(
    (x) => _m(x)['is_primary'] == true,
    orElse: () => list.isNotEmpty ? list.first : {},
  ));
  return VisitJourney(
    visitCode: ((d['ticket_no'] as String?) ?? '').replaceAll('#', ''),
    pathway: 'Cardiac pathway',
    patientName: (patient['full_name'] as String?) ?? '',
    condition: (primary['diagnosis'] as String?) ?? '',
    admitted: 'Admitted ${_dateLabel(d['arrived_at'] as String?)}',
    stages: _stagesFromTimeline(_l(d['timeline']), (d['current_stage'] as String?) ?? ''),
  );
}

List<VisitStage> _stagesFromTimeline(List timeline, String currentStage) {
  final Map<String, Map<String, dynamic>> firstEntry = {};
  for (final e in timeline) {
    final m = _m(e);
    final st = m['stage'] as String?;
    if (st != null && !firstEntry.containsKey(st)) firstEntry[st] = m;
  }
  final currentIdx = _stageOrder.indexOf(currentStage);
  final stages = <VisitStage>[];
  for (int i = 0; i < _stageOrder.length; i++) {
    final key = _stageOrder[i];
    final entry = firstEntry[key];
    final status = (currentIdx >= 0 && i < currentIdx)
        ? 'done'
        : (i == currentIdx ? 'current' : 'upcoming');
    stages.add(VisitStage(
      // numeric timeline id when available (so it can be rated), else the key
      id: entry != null ? entry['id'].toString() : key,
      title: _stageNames[key] ?? key,
      status: status,
      time: entry != null ? _timeLabel(entry['entered_at'] as String?) : '',
      detail: entry != null ? ((entry['decision_note'] as String?) ?? '') : 'Pending',
    ));
  }
  return stages;
}

Medicine _medicineFromApi(Map<String, dynamic> j) {
  final drug = (j['drug_name'] as String?) ?? '';
  return Medicine(
    id: j['id'].toString(),
    name: drug,
    dose: (j['dose'] as String?) ?? '',
    schedule: _sentence((j['frequency'] as String?) ?? ''),
    photoAsset: _photoFor(drug),
  );
}

String _photoFor(String drug) {
  final d = drug.toLowerCase();
  if (d.contains('aspirin')) return 'assets/images/meds/aspirin.jpeg';
  if (d.contains('atorvastatin')) return 'assets/images/meds/atorvastatin.jpeg';
  if (d.contains('clopidogrel')) return 'assets/images/meds/clopidogrel.jpeg';
  return '';
}