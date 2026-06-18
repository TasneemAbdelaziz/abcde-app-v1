import 'vital.dart';

/// One set of vital signs, parsed from `GET /visits/#{serial}/vitals`.
///
/// The endpoint returns a list of readings over time; the Home screen shows
/// the most recent one (see PatientApiRepository.getLatestVitals).
class VitalsReading {
  final DateTime? takenAt;
  final int? systolicBp;
  final int? diastolicBp;
  final int? pulse;
  final int? respiratoryRate;
  final int? spo2;
  final String temperature; // arrives as a string, e.g. "37.0"
  final int? painScore;
  final String consciousnessAvpu;

  const VitalsReading({
    required this.takenAt,
    required this.systolicBp,
    required this.diastolicBp,
    required this.pulse,
    required this.respiratoryRate,
    required this.spo2,
    required this.temperature,
    required this.painScore,
    required this.consciousnessAvpu,
  });

  factory VitalsReading.fromJson(Map<String, dynamic> j) {
    int? toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}');
    return VitalsReading(
      takenAt: DateTime.tryParse((j['taken_at'] ?? '').toString()),
      systolicBp: toInt(j['systolic_bp']),
      diastolicBp: toInt(j['diastolic_bp']),
      pulse: toInt(j['pulse']),
      respiratoryRate: toInt(j['respiratory_rate']),
      spo2: toInt(j['spo2']),
      temperature: (j['temperature'] ?? '').toString(),
      painScore: toInt(j['pain_score']),
      consciousnessAvpu: (j['consciousness_avpu'] ?? '').toString(),
    );
  }

  /// Builds the display strip for the Home screen. Missing values show '—'.
  List<Vital> toVitals() {
    String s(Object? v) => (v == null || '$v'.isEmpty) ? '—' : '$v';
    final bp = (systolicBp != null && diastolicBp != null)
        ? '$systolicBp/$diastolicBp'
        : '—';
    return [
      Vital(label: 'Heart Rate', value: s(pulse), unit: 'bpm'),
      Vital(label: 'SpO₂', value: s(spo2), unit: '%'),
      Vital(label: 'Blood Pressure', value: bp, unit: ''),
      Vital(label: 'Temperature', value: s(temperature), unit: '°C'),
      Vital(label: 'Respiration', value: s(respiratoryRate), unit: '/min'),
    ];
  }
}
