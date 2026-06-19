/// Basic header information for the Journey screen.
class JourneyHeader {
  final String visitId;
  final String pathway;
  final String patientName;
  final String diagnosis;
  final String admissionDate;

  const JourneyHeader({
    required this.visitId,
    required this.pathway,
    required this.patientName,
    required this.diagnosis,
    required this.admissionDate,
  });

  factory JourneyHeader.fromMock() {
    return const JourneyHeader(
      visitId: 'ALM-20413',
      pathway: 'Cardiac pathway',
      patientName: 'Ahmed Al-Rashid',
      diagnosis: 'Acute coronary syndrome',
      admissionDate: 'Admitted Jun 11, 2026',
    );
  }
}
