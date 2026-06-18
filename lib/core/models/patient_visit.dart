/// The patient's current hospital visit, parsed from `GET /visits/#{serial}`.
///
/// Named [PatientVisit] (not `Visit`) to avoid clashing with the "My Visits"
/// list model in `visit.dart`. Holds the care-journey state (current stage),
/// admission info (arrival time, location/room) and the treating doctor &
/// department. The `#` in the visit id is URL-encoded as `%23` by the repo.
class PatientVisit {
  final String ticketNo;
  final String arrivalType;
  final DateTime? arrivedAt;
  final String triageClassification;
  final String currentStage; // e.g. 'diagnosis'
  final String visitStatus; // e.g. 'open'
  final String doctorName;
  final String departmentName;
  final String locationName; // e.g. 'Emergency Bay 2'
  final String floor;

  const PatientVisit({
    required this.ticketNo,
    required this.arrivalType,
    required this.arrivedAt,
    required this.triageClassification,
    required this.currentStage,
    required this.visitStatus,
    required this.doctorName,
    required this.departmentName,
    required this.locationName,
    required this.floor,
  });

  factory PatientVisit.fromJson(Map<String, dynamic> data) {
    final doctor = data['doctor'];
    final dept = data['department'];
    final loc = data['location'];
    String pick(dynamic obj, String key) =>
        obj is Map<String, dynamic> ? (obj[key] ?? '').toString() : '';

    return PatientVisit(
      ticketNo: (data['ticket_no'] ?? '').toString(),
      arrivalType: (data['arrival_type'] ?? '').toString(),
      arrivedAt: DateTime.tryParse((data['arrived_at'] ?? '').toString()),
      triageClassification: (data['triage_classification'] ?? '').toString(),
      currentStage: (data['current_stage'] ?? '').toString(),
      visitStatus: (data['visit_status'] ?? '').toString(),
      doctorName: pick(doctor, 'full_name'),
      departmentName: pick(dept, 'department_name'),
      locationName: pick(loc, 'location_name'),
      floor: pick(loc, 'floor'),
    );
  }

  /// The care-journey stage as (1-based index, total, pretty title).
  ///
  /// Maps the backend's `current_stage` key against the canonical ED → cardiac
  /// pathway. Unknown keys return index 0 and just show the prettified key.
  CareStage get stage {
    final i = _stages.indexWhere((s) => s.$1 == currentStage.toLowerCase());
    if (i < 0) {
      return CareStage(index: 0, total: _stages.length, title: prettyStage(currentStage));
    }
    return CareStage(index: i + 1, total: _stages.length, title: _stages[i].$2);
  }

  /// Pretty English name for a stage code (e.g. 'cath' → 'Catheterization').
  static String prettyStage(String code) {
    final i = _stages.indexWhere((s) => s.$1 == code.toLowerCase());
    if (i >= 0) return _stages[i].$2;
    if (code.isEmpty) return '—';
    return code[0].toUpperCase() + code.substring(1);
  }

  // Confirmed valid `current_stage` values from the backend: diagnosis, cath,
  // recovery, discharge (registration/triage assumed at the start of the flow).
  static const List<(String, String)> _stages = [
    ('registration', 'Registration'),
    ('triage', 'Triage'),
    ('diagnosis', 'Diagnosis'),
    ('cath', 'Catheterization'),
    ('recovery', 'Recovery & Monitoring'),
    ('discharge', 'Discharge'),
  ];
}

/// Where the patient is in their care journey.
class CareStage {
  final int index; // 1-based; 0 if unknown
  final int total;
  final String title;
  const CareStage({
    required this.index,
    required this.total,
    required this.title,
  });
}
