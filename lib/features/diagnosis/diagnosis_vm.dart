import 'package:flutter/foundation.dart';

import '../../core/models/diagnosis.dart';
import '../../core/repositories/patient_care_api_repository.dart';

/// ViewModel for the Diagnosis screen.
///
/// Holds the structured [Diagnosis] the screen displays. The backend returns
/// the clinical free-text in its source language (English); when the app is set
/// to another language we translate the readable fields on demand via
/// `POST /documentation/translate` and cache the result per language.
class DiagnosisVm extends ChangeNotifier {
  final PatientCareApiRepository _repo;

  DiagnosisVm(this._repo) {
    load();
  }

  bool loading = false;
  bool translating = false;
  String? error;

  /// What the screen shows — the original, or a translated copy.
  Diagnosis? diagnosis;

  // The raw (source-language) diagnosis from the backend, and the locale the
  // currently-shown [diagnosis] reflects.
  Diagnosis? _original;
  String _shownLang = 'en';

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      _original = await _repo.getDiagnosis();
      diagnosis = _original;
      _shownLang = 'en';
    } catch (e) {
      error = 'Could not load the diagnosis.';
    }

    loading = false;
    notifyListeners();
  }

  /// Translates the loaded diagnosis into [lang] via the backend. A no-op when
  /// nothing is loaded, when already showing that language, or while a
  /// translation is in flight. Passing 'en' (or empty) restores the original.
  Future<void> ensureTranslated(String lang) async {
    final original = _original;
    if (original == null || translating) return;

    // Source language — show the original text.
    if (lang.isEmpty || lang == 'en') {
      if (_shownLang != 'en') {
        diagnosis = original;
        _shownLang = 'en';
        notifyListeners();
      }
      return;
    }

    if (_shownLang == lang) return;

    translating = true;
    notifyListeners();
    try {
      Future<String> tr(String s) => _repo.translateText(s, lang);

      // Translate only the readable clinical text — never names, dates or
      // durations (which live in the video subtitles).
      final condition = await tr(original.condition);
      final department = await tr(original.department);
      final explanation = await tr(original.explanation);
      final caseTitle = await tr(original.caseVideo.title);
      final prevention = <DiagnosisVideo>[
        for (final v in original.preventionVideos)
          v.copyWith(title: await tr(v.title)),
      ];

      diagnosis = original.copyWith(
        condition: condition,
        department: department,
        explanation: explanation,
        caseVideo: original.caseVideo.copyWith(title: caseTitle),
        preventionVideos: prevention,
      );
      _shownLang = lang;
    } catch (_) {
      // Keep the original on any failure.
    } finally {
      translating = false;
      notifyListeners();
    }
  }
}
