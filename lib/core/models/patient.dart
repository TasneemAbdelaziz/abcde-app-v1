/// A patient. Immutable: build a new one with [copyWith] instead of mutating.
class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String room; // e.g. '204 Â· Ward B'
  final String condition; // e.g. 'Acute Coronary Syndrome'
  final String admitted; // display date, e.g. 'Jun 11, 2026'
  final String dischargeEst; // display date
  final String mrn; // medical record number

  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.room,
    required this.condition,
    required this.admitted,
    required this.dischargeEst,
    required this.mrn,
  });

  Patient copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? room,
    String? condition,
    String? admitted,
    String? dischargeEst,
    String? mrn,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      room: room ?? this.room,
      condition: condition ?? this.condition,
      admitted: admitted ?? this.admitted,
      dischargeEst: dischargeEst ?? this.dischargeEst,
      mrn: mrn ?? this.mrn,
    );
  }

  /// Sample patient used while there is no backend.
  /// TODO: replace with data from the API once it exists.
  factory Patient.fromMock() {
    return const Patient(
      id: 'p-001',
      name: 'Ahmed Al-Rashid',
      age: 32,
      gender: 'Male',
      room: '204 Â· Ward B',
      condition: 'Acute Coronary Syndrome',
      admitted: 'Jun 11, 2026',
      dischargeEst: 'Jun 16, 2026',
      mrn: 'ALM-20413',
    );
  }
}
