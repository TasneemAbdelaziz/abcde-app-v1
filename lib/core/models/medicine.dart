/// A prescribed medicine with its dosage schedule.
class Medicine {
  final String id;
  final String name;
  final String dose; // e.g. '500 mg'
  final String schedule; // e.g. 'Twice a day'

  const Medicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.schedule,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? dose,
    String? schedule,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      schedule: schedule ?? this.schedule,
    );
  }

  /// One sample medicine. TODO: replace with API data.
  factory Medicine.fromMock() {
    return const Medicine(
      id: 'm-001',
      name: 'Amoxicillin',
      dose: '500 mg',
      schedule: 'Twice a day',
    );
  }
}
