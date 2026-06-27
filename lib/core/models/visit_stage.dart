/// One stage in the patient's treatment journey (e.g. Admission, Diagnosis,
/// Treatment, Discharge). Each stage can be rated by the patient.
class VisitStage {
  final String id;
  final String title;
  final String status; // e.g. 'done', 'current', 'upcoming'
  final int rating; // 0..5 stars, 0 = not rated yet

  /// The backend stage code (e.g. 'triage', 'cath'), used to look up a
  /// translated stage name. Empty when unknown.
  final String code;

  /// Optional timestamp shown next to the stage, e.g. '08:12'. Empty if none.
  final String time;

  /// Optional one-line detail, e.g. 'Reception desk', 'Pending'. Empty if none.
  final String detail;

  const VisitStage({
    required this.id,
    required this.title,
    required this.status,
    this.rating = 0,
    this.code = '',
    this.time = '',
    this.detail = '',
  });

  VisitStage copyWith({
    String? id,
    String? title,
    String? status,
    int? rating,
    String? code,
    String? time,
    String? detail,
  }) {
    return VisitStage(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      code: code ?? this.code,
      time: time ?? this.time,
      detail: detail ?? this.detail,
    );
  }

  /// One sample stage. See PatientRepository.getStages() for the full list.
  /// TODO: replace with API data.
  factory VisitStage.fromMock() {
    return const VisitStage(
      id: 's-001',
      title: 'Admission',
      status: 'done',
      rating: 5,
    );
  }
}