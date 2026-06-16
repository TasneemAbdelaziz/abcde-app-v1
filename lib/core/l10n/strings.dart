/// Very simple localization helper for the 4 supported languages:
/// EN (English), AR (Arabic), RU (Russian), ZH (Chinese).
///
/// This is intentionally beginner-friendly: just a nested Map. When the app
/// grows, migrate to Flutter's official `flutter_localizations` + ARB files.
///
/// Usage: `AppStrings.of('ar', 'appTitle')`.
class AppStrings {
  AppStrings._();

  /// The 4 supported language codes.
  static const List<String> supported = ['en', 'ar', 'ru', 'zh'];

  /// Languages written right-to-left. Only Arabic here.
  static const List<String> _rtl = ['ar'];

  /// Returns true if the given language should render right-to-left.
  static bool isRtl(String lang) => _rtl.contains(lang);

  /// key -> { lang -> text }
  ///
  /// TODO: add a key for every label shown in the UI, in all 4 languages.
  static const Map<String, Map<String, String>> _values = {
    'appTitle': {
      'en': 'Alamein Patient Portal',
      'ar': 'بوابة مرضى العلمين',
      'ru': 'Портал пациента Аламейн',
      'zh': '阿拉曼患者门户',
    },
    'home': {
      'en': 'Home',
      'ar': 'الرئيسية',
      'ru': 'Главная',
      'zh': '首页',
    },
    'rateTitle': {
      'en': 'Rate this stage',
      'ar': 'قيّم هذه المرحلة',
      'ru': 'Оцените этот этап',
      'zh': '为此阶段评分',
    },
    'submit': {
      'en': 'Submit',
      'ar': 'إرسال',
      'ru': 'Отправить',
      'zh': '提交',
    },
    // TODO: add more keys (login, reports, medicines, ...).
  };

  /// Looks up a key for a language. Falls back to English, then to the key
  /// itself, so the UI never crashes on a missing translation.
  static String of(String lang, String key) {
    final entry = _values[key];
    if (entry == null) return key;
    return entry[lang] ?? entry['en'] ?? key;
  }
}
