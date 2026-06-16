/// One stage in the patient's treatment journey (e.g. Admission, Diagnosis,
/// Treatment, Discharge). Each stage can be rated by the patient.
class VisitStage {
  final String id;
  final String title;
  final String status; // e.g. 'done', 'current', 'upcoming'
  final int rating; // 0..5 stars, 0 = not rated yet

  const VisitStage({
    required this.id,
    required this.title,
    required this.status,
    this.rating = 0,
  });

  VisitStage copyWith({
    String? id,
    String? title,
    String? status,
    int? rating,
  }) {
    return VisitStage(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      rating: rating ?? this.rating,
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
