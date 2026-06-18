import 'diagnosis.dart'; // reuses DiagnosisVideo / DiagnosisVideoKind

/// Everything shown on the Treatment Plan screen: recovery progress, quick
/// stats, the two explainer videos, today's medicine timeline, daily goals,
/// and upcoming appointments.
class TreatmentPlan {
  final String doctorName; // 'Dr. Abu Bakr Al-Fahham'
  final String doctorInitials; // 'AB'
  final String doctorMeta; // 'Cardiology · Updated Jun 11, 2026'

  // Today's recovery
  final int recoveryPercent; // 63
  final int tasksCompleted; // 5
  final int tasksTotal; // 8

  // Quick stats
  final String nextDose; // '2:00 PM'
  final String toDischarge; // '2 days'
  final int adherencePercent; // 92

  // Explainer videos (reuse the diagnosis video model + player)
  final DiagnosisVideo surgeryVideo;
  final DiagnosisVideo afterSurgeryVideo;

  final List<MedicineDose> timeline;
  final List<TreatmentGoal> goals;
  final List<UpcomingItem> upcoming;

  const TreatmentPlan({
    required this.doctorName,
    required this.doctorInitials,
    required this.doctorMeta,
    required this.recoveryPercent,
    required this.tasksCompleted,
    required this.tasksTotal,
    required this.nextDose,
    required this.toDischarge,
    required this.adherencePercent,
    required this.surgeryVideo,
    required this.afterSurgeryVideo,
    required this.timeline,
    required this.goals,
    required this.upcoming,
  });

  /// Sample plan used while there is no backend.
  /// TODO: replace with data from the API once it exists.
  factory TreatmentPlan.fromMock() {
    return const TreatmentPlan(
      doctorName: 'Dr. Abu Bakr Al-Fahham',
      doctorInitials: 'AB',
      doctorMeta: 'Cardiology · Updated Jun 11, 2026',
      recoveryPercent: 63,
      tasksCompleted: 5,
      tasksTotal: 8,
      nextDose: '2:00 PM',
      toDischarge: '2 days',
      adherencePercent: 92,
      surgeryVideo: DiagnosisVideo(
        id: 'tv-surgery',
        title: 'How your catheterization works',
        subtitle: 'Step-by-step of the procedure · 3:50',
        duration: '3:50',
        badge: 'Procedure explainer',
        kind: DiagnosisVideoKind.explainer,
        assetPath: 'assets/videos/your_surgery_explained.mp4',
        available: true, // TODO: set true once the file is added.
      ),
      afterSurgeryVideo: DiagnosisVideo(
        id: 'tv-after',
        title: 'What happens after surgery',
        subtitle: 'Recovery, wound care & medication · 3:10',
        duration: '3:10',
        badge: 'Post-surgery guide',
        kind: DiagnosisVideoKind.prevention,
        assetPath: 'assets/videos/after_your_surgery.mp4',
        available: true, // TODO: set true once the file is added.
      ),
      timeline: [
        MedicineDose(
          time: '08:00 AM',
          period: 'MORNING',
          name: 'Clopidogrel 75 mg',
          note: 'Take with breakfast',
          status: DoseStatus.taken,
        ),
        MedicineDose(
          time: '09:00 AM',
          period: 'MORNING',
          name: 'Aspirin 81 mg',
          note: 'After breakfast',
          status: DoseStatus.taken,
        ),
        MedicineDose(
          time: '02:00 PM',
          period: 'AFTERNOON',
          name: 'Aspirin 81 mg',
          note: 'Due now · with water',
          status: DoseStatus.dueNow,
        ),
        MedicineDose(
          time: '09:00 PM',
          period: 'EVENING',
          name: 'Atorvastatin 40 mg',
          note: 'Before bedtime',
          status: DoseStatus.upcoming,
        ),
      ],
      goals: [
        TreatmentGoal(
          title: 'Light walking, 10 min',
          subtitle: 'Supervised by nursing',
          status: GoalStatus.pending,
        ),
        TreatmentGoal(
          title: 'Low-salt lunch',
          subtitle: 'Dietary plan',
          status: GoalStatus.done,
        ),
      ],
      upcoming: [
        UpcomingItem(
          title: 'Cardiology follow-up',
          subtitle: 'Dr. Abu Bakr Al-Fahham · in 7 days',
        ),
        UpcomingItem(
          title: 'Echocardiogram',
          subtitle: 'Imaging dept · in 14 days',
        ),
      ],
    );
  }
}

/// A scheduled dose in today's medicine timeline.
enum DoseStatus { taken, dueNow, upcoming }

class MedicineDose {
  final String time; // '08:00 AM'
  final String period; // 'MORNING'
  final String name; // 'Aspirin 81 mg'
  final String note; // 'After breakfast'
  final DoseStatus status;

  const MedicineDose({
    required this.time,
    required this.period,
    required this.name,
    required this.note,
    required this.status,
  });
}

/// A daily recovery goal.
enum GoalStatus { pending, done }

class TreatmentGoal {
  final String title; // 'Light walking, 10 min'
  final String subtitle; // 'Supervised by nursing'
  final GoalStatus status;

  const TreatmentGoal({
    required this.title,
    required this.subtitle,
    required this.status,
  });
}

/// An upcoming appointment / procedure.
class UpcomingItem {
  final String title; // 'Cardiology follow-up'
  final String subtitle; // 'Dr. Abu Bakr Al-Fahham · in 7 days'

  const UpcomingItem({required this.title, required this.subtitle});
}