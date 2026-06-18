/// The signed-in patient, parsed from `GET /auth/me` (the `data` object).
///
/// The API gives us: serial, name, gender (F/M), date of birth, phone,
/// city/district, chronic conditions, preferred language and national id.
/// Anything the Home design shows beyond this (room/ward, admission &
/// discharge dates, current acute condition, care-journey stage, live vitals)
/// is NOT in the API yet — see the notes in HomeVm.
class PatientProfile {
  final String serial;
  final String name;
  final String gender; // raw 'F' / 'M'
  final DateTime? dateOfBirth;
  final String phone;
  final String cityDistrict;
  final String chronicConditions;
  final String preferredLanguage;
  final String nationalId;
  final int? serverAge; // `age` from /patients/{serial}, if present
  final int carePoints;

  const PatientProfile({
    required this.serial,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.phone,
    required this.cityDistrict,
    required this.chronicConditions,
    required this.preferredLanguage,
    required this.nationalId,
    this.serverAge,
    this.carePoints = 0,
  });

  /// 'Female' / 'Male' for display; falls back to the raw value.
  String get genderLabel {
    switch (gender.toUpperCase()) {
      case 'F':
        return 'Female';
      case 'M':
        return 'Male';
      default:
        return gender;
    }
  }

  /// Age in years. Prefers the server's `age`; otherwise computes from DOB.
  int? get age {
    if (serverAge != null) return serverAge;
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  /// Parses the `data` object of `GET /patients/{serial}` (patient fields are
  /// at the top level there, plus `age` and `care_points`).
  factory PatientProfile.fromPatientJson(Map<String, dynamic> p) {
    int? toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}');
    return PatientProfile(
      serial: (p['patient_serial'] ?? '').toString(),
      name: (p['full_name'] ?? '').toString(),
      gender: (p['gender'] ?? '').toString(),
      dateOfBirth: DateTime.tryParse((p['date_of_birth'] ?? '').toString()),
      phone: (p['phone'] ?? '').toString(),
      cityDistrict: (p['city_district'] ?? '').toString(),
      chronicConditions: (p['chronic_conditions'] ?? '').toString(),
      preferredLanguage: (p['preferred_language'] ?? '').toString(),
      nationalId: (p['national_id'] ?? '').toString(),
      serverAge: toInt(p['age']),
      carePoints: toInt(p['care_points']) ?? 0,
    );
  }

  /// Parses the `data` object of `GET /auth/me`. Defensive: missing fields
  /// become empty strings / null so the UI never crashes on partial data.
  factory PatientProfile.fromMe(Map<String, dynamic> data) {
    final raw = data['patient'];
    final p = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
    return PatientProfile(
      serial: (p['patient_serial'] ?? '').toString(),
      name: (p['full_name'] ?? data['name'] ?? '').toString(),
      gender: (p['gender'] ?? '').toString(),
      dateOfBirth: DateTime.tryParse((p['date_of_birth'] ?? '').toString()),
      phone: (p['phone'] ?? '').toString(),
      cityDistrict: (p['city_district'] ?? '').toString(),
      chronicConditions: (p['chronic_conditions'] ?? '').toString(),
      preferredLanguage: (p['preferred_language'] ?? '').toString(),
      nationalId: (p['national_id'] ?? data['national_id'] ?? '').toString(),
    );
  }
}
