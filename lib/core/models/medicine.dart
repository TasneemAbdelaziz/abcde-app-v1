/// A prescribed medicine with its dosage schedule.
class Medicine {
  final String id;
  final String name;
  final String dose; // e.g. '500 mg'
  final String schedule; // e.g. 'Twice a day'

  /// Optional product-photo asset, e.g. 'assets/images/meds/aspirin.png'.
  /// Falls back to a pill icon if the file isn't there yet.
  final String photoAsset;

  const Medicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.schedule,
    this.photoAsset = '',
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? dose,
    String? schedule,
    String? photoAsset,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      schedule: schedule ?? this.schedule,
      photoAsset: photoAsset ?? this.photoAsset,
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