/// The patient's current diagnosis, presented the way the Diagnosis screen
/// shows it: a headline condition, a doctor-recorded explainer video, a
/// plain-language "what this means" summary, and a few prevention videos.
///
/// Immutable: build a new one with [copyWith] instead of mutating.
class Diagnosis {
  final String condition; // e.g. 'Acute Coronary Syndrome'
  final String department; // e.g. 'Cardiology'
  final String doctor; // e.g. 'Dr. Amira Fouad'
  final String admitted; // display date, e.g. 'Jun 11, 2026'

  /// Plain-language explanation shown under "What this means".
  final String explanation;

  /// The "Understanding your case" explainer video.
  final DiagnosisVideo caseVideo;

  /// Videos under "How to prevent it from worsening".
  final List<DiagnosisVideo> preventionVideos;

  const Diagnosis({
    required this.condition,
    required this.department,
    required this.doctor,
    required this.admitted,
    required this.explanation,
    required this.caseVideo,
    required this.preventionVideos,
  });

  Diagnosis copyWith({
    String? condition,
    String? department,
    String? doctor,
    String? admitted,
    String? explanation,
    DiagnosisVideo? caseVideo,
    List<DiagnosisVideo>? preventionVideos,
  }) {
    return Diagnosis(
      condition: condition ?? this.condition,
      department: department ?? this.department,
      doctor: doctor ?? this.doctor,
      admitted: admitted ?? this.admitted,
      explanation: explanation ?? this.explanation,
      caseVideo: caseVideo ?? this.caseVideo,
      preventionVideos: preventionVideos ?? this.preventionVideos,
    );
  }

  /// Sample diagnosis used while there is no backend.
  /// TODO: replace with data from the API once it exists.
  factory Diagnosis.fromMock() {
    return const Diagnosis(
      condition: 'Acute Coronary Syndrome',
      department: 'Cardiology',
      doctor: 'Dr. Abu Bakr Al-Fahham',
      admitted: 'Jun 11, 2026',
      explanation:
          'Your heart\'s blood supply was briefly reduced by a narrowed '
          'coronary artery. A catheterization reopened the artery and restored '
          'normal blood flow. You are now being monitored while you recover — '
          'your vital signs are stable and improving.',
      caseVideo: DiagnosisVideo(
        id: 'v-case',
        title: 'Understanding your case',
        subtitle: 'Dr. Abu Bakr Al-Fahham · 2:45 · with subtitles',
        duration: '2:45',
        badge: 'Personalised explainer',
        kind: DiagnosisVideoKind.explainer,
        assetPath: 'assets/videos/understanding_your_case.mp4',
      ),
      preventionVideos: [
        DiagnosisVideo(
          id: 'v-prevent-1',
          title: 'Daily habits that protect your heart',
          subtitle: 'Diet, activity & medication · 4:20',
          duration: '4:20',
          badge: 'Prevention guide',
          kind: DiagnosisVideoKind.prevention,
          assetPath: 'assets/videos/daily_habits.mp4',
        ),
        DiagnosisVideo(
          id: 'v-prevent-2',
          title: 'Warning signs you shouldn\'t ignore',
          subtitle: 'Know when to call your doctor · 3:35',
          duration: '3:35',
          badge: 'Stay alert',
          kind: DiagnosisVideoKind.alert,
          assetPath: 'assets/videos/signs_you_shouldn\'t_ignore.mp4',
        ),
      ],
    );
  }
}

/// What a diagnosis video is about. Drives the small badge icon + accent shown
/// in the bottom-left corner of each video card.
enum DiagnosisVideoKind { explainer, prevention, alert }

/// A single video card on the Diagnosis screen.
class DiagnosisVideo {
  final String id;
  final String title; // e.g. 'Understanding your case'
  final String subtitle; // line under the title
  final String duration; // bottom-right label, e.g. '2:45'
  final String badge; // bottom-left label, e.g. 'Personalised explainer'
  final DiagnosisVideoKind kind;

  /// Bundled asset path for the local video file, e.g.
  /// 'assets/videos/understanding_your_case.mp4'. Declared under
  /// `assets/videos/` in pubspec.yaml.
  final String assetPath;

  /// Whether the video file has actually been added yet. When false the card
  /// shows a "Coming soon" state and does not open the player. Defaults to
  /// true. TODO: drop this once all videos exist (or derive from the API).
  final bool available;

  const DiagnosisVideo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.badge,
    required this.kind,
    required this.assetPath,
    this.available = true,
  });

  DiagnosisVideo copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? duration,
    String? badge,
    DiagnosisVideoKind? kind,
    String? assetPath,
    bool? available,
  }) {
    return DiagnosisVideo(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      duration: duration ?? this.duration,
      badge: badge ?? this.badge,
      kind: kind ?? this.kind,
      assetPath: assetPath ?? this.assetPath,
      available: available ?? this.available,
    );
  }
}