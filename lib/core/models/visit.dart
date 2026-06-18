import 'visit_stage.dart';

/// Whether a visit is still ongoing or finished. Only [active] visits can be
/// opened to view their Care Journey timeline.
enum VisitStatus { active, completed }

/// One hospital visit shown in the "My Visits" list.
///
/// Active visits carry a [journey] (the stage-by-stage Care Journey timeline);
/// completed visits carry a [rating] instead and have no journey.
class Visit {
  final String id;
  final VisitStatus status;
  final String title; // 'Acute coronary syndrome — catheterization'
  final String doctorName; // 'Dr. Amira Fouad'
  final String doctorInitials; // 'AF' (shown in the avatar circle)
  final String department; // 'Cardiology · CCU'
  final String dateLabel; // 'Jun 11, 2026 · 08:12'

  // Active visits only -----------------------------------------------------
  final int currentStage; // 5
  final int totalStages; // 8
  final String progressLabel; // 'in progress'

  // Completed visits only --------------------------------------------------
  final double rating; // 4.6 (0 when not applicable)

  /// The Care Journey timeline. Non-null for active visits, null otherwise.
  final VisitJourney? journey;

  const Visit({
    required this.id,
    required this.status,
    required this.title,
    required this.doctorName,
    required this.doctorInitials,
    required this.department,
    required this.dateLabel,
    this.currentStage = 0,
    this.totalStages = 0,
    this.progressLabel = '',
    this.rating = 0,
    this.journey,
  });

  bool get isActive => status == VisitStatus.active;

  Visit copyWith({
    VisitStatus? status,
    String? title,
    String? doctorName,
    String? doctorInitials,
    String? department,
    String? dateLabel,
    int? currentStage,
    int? totalStages,
    String? progressLabel,
    double? rating,
    VisitJourney? journey,
  }) {
    return Visit(
      id: id,
      status: status ?? this.status,
      title: title ?? this.title,
      doctorName: doctorName ?? this.doctorName,
      doctorInitials: doctorInitials ?? this.doctorInitials,
      department: department ?? this.department,
      dateLabel: dateLabel ?? this.dateLabel,
      currentStage: currentStage ?? this.currentStage,
      totalStages: totalStages ?? this.totalStages,
      progressLabel: progressLabel ?? this.progressLabel,
      rating: rating ?? this.rating,
      journey: journey ?? this.journey,
    );
  }

  /// Sample visits used while there is no backend.
  /// TODO: replace with data from the API once it exists.
  static List<Visit> mockList() {
    return [
      const Visit(
        id: 'visit-001',
        status: VisitStatus.active,
        title: 'Acute coronary syndrome — catheterization',
        doctorName: 'Dr. Abu Bakr Al-Fahham',
        doctorInitials: 'AB',
        department: 'Cardiology · CCU',
        dateLabel: 'Jun 11, 2026 · 08:12',
        currentStage: 5,
        totalStages: 8,
        progressLabel: 'in progress',
        journey: VisitJourney(
          visitCode: 'ALM-20413',
          pathway: 'Cardiac pathway',
          patientName: 'Ahmed Al-Rashid',
          condition: 'Acute coronary syndrome',
          admitted: 'Admitted Jun 11, 2026',
          stages: [
            VisitStage(
              id: 'st-1',
              title: 'Arrival & Registration',
              status: 'done',
              rating: 5,
              time: '08:12',
              detail: 'Reception desk',
            ),
            VisitStage(
              id: 'st-2',
              title: 'Triage Assessment',
              status: 'done',
              rating: 4,
              time: '08:20',
              detail: 'Emergency nurse',
            ),
            VisitStage(
              id: 'st-3',
              title: 'Diagnosis',
              status: 'done',
              time: '08:45',
              detail: 'ECG & cardiac enzymes',
            ),
            VisitStage(
              id: 'st-4',
              title: 'Catheterization',
              status: 'done',
              time: '10:05',
              detail: 'Cath Lab 2',
            ),
            VisitStage(
              id: 'st-5',
              title: 'Recovery & Monitoring',
              status: 'current',
              detail: 'Coronary Care Unit · in progress',
            ),
            VisitStage(
              id: 'st-6',
              title: 'Ward Admission',
              status: 'upcoming',
              detail: 'Estimated this afternoon',
            ),
            VisitStage(
              id: 'st-7',
              title: 'Discharge Planning',
              status: 'upcoming',
              detail: 'Pending',
            ),
            VisitStage(
              id: 'st-8',
              title: 'Home Follow-up',
              status: 'upcoming',
              detail: 'Pending',
            ),
          ],
        ),
      ),
      const Visit(
        id: 'visit-002',
        status: VisitStatus.completed,
        title: 'Hypertension follow-up',
        doctorName: 'Dr. Hassan Saad',
        doctorInitials: 'HS',
        department: 'Cardiology',
        dateLabel: 'Feb 14, 2026',
        rating: 4.6,
      ),
      const Visit(
        id: 'visit-003',
        status: VisitStatus.completed,
        title: 'Routine cardiac check-up',
        doctorName: 'Dr. Amira Fouad',
        doctorInitials: 'AF',
        department: 'Cardiology',
        dateLabel: 'Nov 3, 2025',
        rating: 5.0,
      ),
    ];
  }
}

/// The Care Journey for an active visit: a header plus the ordered stages.
class VisitJourney {
  final String visitCode; // 'ALM-20413'
  final String pathway; // 'Cardiac pathway'
  final String patientName; // 'Ahmed Al-Rashid'
  final String condition; // 'Acute coronary syndrome'
  final String admitted; // 'Admitted Jun 11, 2026'
  final List<VisitStage> stages;

  const VisitJourney({
    required this.visitCode,
    required this.pathway,
    required this.patientName,
    required this.condition,
    required this.admitted,
    required this.stages,
  });

  VisitJourney copyWith({List<VisitStage>? stages}) {
    return VisitJourney(
      visitCode: visitCode,
      pathway: pathway,
      patientName: patientName,
      condition: condition,
      admitted: admitted,
      stages: stages ?? this.stages,
    );
  }
}