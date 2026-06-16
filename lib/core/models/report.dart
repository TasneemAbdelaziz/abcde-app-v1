/// A medical report or lab result attached to the patient.
class Report {
  final String id;
  final String title;
  final String date; // ISO date string, e.g. '2026-06-10'
  final String type; // e.g. 'lab', 'imaging', 'summary'

  const Report({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
  });

  Report copyWith({
    String? id,
    String? title,
    String? date,
    String? type,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  /// One sample report. TODO: replace with API data.
  factory Report.fromMock() {
    return const Report(
      id: 'r-001',
      title: 'Blood Test — Complete Panel',
      date: '2026-06-10',
      type: 'lab',
    );
  }
}
