/// A single vital reading shown on the Home screen (e.g. Heart Rate 72 bpm).
class Vital {
  final String label;
  final String value;
  final String unit;

  const Vital({
    required this.label,
    required this.value,
    required this.unit,
  });

  Vital copyWith({String? label, String? value, String? unit}) {
    return Vital(
      label: label ?? this.label,
      value: value ?? this.value,
      unit: unit ?? this.unit,
    );
  }

  /// One sample vital. See PatientRepository.getVitals() for the full list.
  /// TODO: replace with live monitor data when the API exists.
  factory Vital.fromMock() {
    return const Vital(label: 'Heart Rate', value: '72', unit: 'bpm');
  }
}
