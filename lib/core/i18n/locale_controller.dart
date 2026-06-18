import 'package:flutter/material.dart';

/// A language the app can switch to. [code] is the locale code; [label] is the
/// name shown in the picker (written in that language so users recognize it).
class AppLanguage {
  final String code;
  final String label;
  const AppLanguage(this.code, this.label);

  Locale get locale => Locale(code);
}

/// Holds the current app language and lets any widget switch it.
///
/// Register it once in main.dart as a ChangeNotifierProvider, point
/// `MaterialApp.locale` at [locale], and read strings with `t('key')`.
/// Missing keys fall back to English, then to the key itself.
class LocaleController extends ChangeNotifier {
  /// The languages offered in the globe (🌐) picker.
  static const List<AppLanguage> supported = [
    AppLanguage('en', 'English'),
    AppLanguage('ar', 'العربية'),
    AppLanguage('ru', 'Русский'),
    AppLanguage('zh', '中文'),
  ];

  static List<Locale> get supportedLocales =>
      supported.map((l) => l.locale).toList();

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  /// The currently selected language code (e.g. 'en', 'ar').
  String get code => _locale.languageCode;

  void setLocale(Locale value) {
    if (value.languageCode == _locale.languageCode) return;
    _locale = value;
    notifyListeners();
  }

  /// Looks up a translated string for the current language.
  String t(String key) {
    final lang = _strings[code] ?? _strings['en']!;
    return lang[key] ?? _strings['en']![key] ?? key;
  }

  // --- Translation table -----------------------------------------------------
  // Add a key to every language map when you add a new string to the UI.
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'sign_in': 'Sign In',
      'login_subtitle': 'Access your care at Alamein Model Hospital',
      'tab_id_password': 'ID & Password',
      'tab_qr': 'QR Code',
      'national_id': 'National ID',
      'national_id_hint': '30xxxxxxxxxxxxxxxxx',
      'password': 'Password',
      'password_hint': 'Enter your password',
      'qr_box_hint': 'Point your camera at your patient QR wristband',
      'qr_token': 'QR token',
      'qr_token_hint': 'QR-XXXXXXXXXX',
      'scan_qr': 'Scan QR code',
      'log_in': 'Log In',
      'footer': 'Alamein Model Hospital · AIU',
      'choose_language': 'Choose language',
      'notif_care_advanced': 'Your care advanced to',
      'notif_default': 'Notification',
      'notif_mark_all': 'Mark all read',
      'notif_empty_title': "You're all caught up",
      'notif_empty_sub': 'No notifications yet.',
      'retry': 'Retry',
      'onb_about': 'ABOUT THE HOSPITAL',
      'onb_next': 'Next',
      'onb_open_app': 'Open Patient App',
      'onb_empowered': 'EMPOWERED BY AIU',
      'onb_s1_title': "Matrouh's Largest Medical Hub",
      'onb_s1_body': 'A leading healthcare destination serving Matrouh, New '
          'Alamein, the North Coast, residents, visitors, and medical tourism '
          'patients.',
      'onb_s2_title': 'Multi-Specialty Excellence',
      'onb_s2_body': 'More than 20 departments bring specialized care together, '
          'including cardiology, neurosurgery, emergency, radiology, stroke '
          'care, and surgery.',
      'onb_s3_title': 'AI-Powered Imaging',
      'onb_s3_body': 'Advanced MRI, CT, and catheterization technologies support '
          'faster diagnosis and more precise clinical decisions.',
      'onb_s4_title': 'Quality-Driven Care',
      'onb_s4_body': 'Built around safety, clinical quality, patient experience, '
          'and trusted healthcare standards for every stage of care.',
    },
    'ar': {
      'sign_in': 'تسجيل الدخول',
      'login_subtitle': 'تابع رعايتك في مستشفى العلمين النموذجي',
      'tab_id_password': 'الرقم القومي وكلمة المرور',
      'tab_qr': 'رمز QR',
      'national_id': 'الرقم القومي',
      'national_id_hint': '30xxxxxxxxxxxxxxxxx',
      'password': 'كلمة المرور',
      'password_hint': 'أدخل كلمة المرور',
      'qr_box_hint': 'وجّه الكاميرا نحو سوار QR الخاص بالمريض',
      'qr_token': 'رمز QR',
      'qr_token_hint': 'QR-XXXXXXXXXX',
      'scan_qr': 'مسح رمز QR',
      'log_in': 'دخول',
      'footer': 'مستشفى العلمين النموذجي · جامعة العلمين الدولية',
      'choose_language': 'اختر اللغة',
      'notif_care_advanced': 'انتقلت رعايتك إلى',
      'notif_default': 'إشعار',
      'notif_mark_all': 'تعليم الكل كمقروء',
      'notif_empty_title': 'لا توجد إشعارات جديدة',
      'notif_empty_sub': 'لا توجد إشعارات حتى الآن.',
      'retry': 'إعادة المحاولة',
      'onb_about': 'عن المستشفى',
      'onb_next': 'التالي',
      'onb_open_app': 'فتح تطبيق المريض',
      'onb_empowered': 'بدعم من جامعة العلمين الدولية',
      'onb_s1_title': 'أكبر مركز طبي في مطروح',
      'onb_s1_body': 'وجهة رعاية صحية رائدة تخدم مطروح والعلمين الجديدة والساحل '
          'الشمالي والمقيمين والزوار ومرضى السياحة العلاجية.',
      'onb_s2_title': 'تميّز متعدد التخصصات',
      'onb_s2_body': 'أكثر من 20 قسمًا تجمع الرعاية المتخصصة معًا، تشمل القلب '
          'وجراحة المخ والأعصاب والطوارئ والأشعة ورعاية السكتات الدماغية والجراحة.',
      'onb_s3_title': 'تصوير مدعوم بالذكاء الاصطناعي',
      'onb_s3_body': 'تقنيات متقدمة للرنين المغناطيسي والأشعة المقطعية والقسطرة '
          'تدعم تشخيصًا أسرع وقرارات سريرية أكثر دقة.',
      'onb_s4_title': 'رعاية قائمة على الجودة',
      'onb_s4_body': 'مبنية على السلامة والجودة السريرية وتجربة المريض ومعايير '
          'الرعاية الصحية الموثوقة في كل مرحلة من مراحل الرعاية.',
    },
    'ru': {
      'sign_in': 'Вход',
      'login_subtitle': 'Доступ к вашему лечению в больнице Аль-Аламейн',
      'tab_id_password': 'ID и пароль',
      'tab_qr': 'QR-код',
      'national_id': 'Национальный ID',
      'national_id_hint': '30xxxxxxxxxxxxxxxxx',
      'password': 'Пароль',
      'password_hint': 'Введите пароль',
      'qr_box_hint': 'Наведите камеру на QR-браслет пациента',
      'qr_token': 'QR-токен',
      'qr_token_hint': 'QR-XXXXXXXXXX',
      'scan_qr': 'Сканировать QR-код',
      'log_in': 'Войти',
      'footer': 'Больница Аль-Аламейн · AIU',
      'choose_language': 'Выберите язык',
      'notif_care_advanced': 'Ваше лечение перешло к этапу',
      'notif_default': 'Уведомление',
      'notif_mark_all': 'Отметить все как прочитанные',
      'notif_empty_title': 'Новых уведомлений нет',
      'notif_empty_sub': 'Уведомлений пока нет.',
      'retry': 'Повторить',
      'onb_about': 'О БОЛЬНИЦЕ',
      'onb_next': 'Далее',
      'onb_open_app': 'Открыть приложение',
      'onb_empowered': 'ПРИ ПОДДЕРЖКЕ AIU',
      'onb_s1_title': 'Крупнейший медицинский центр Матруха',
      'onb_s1_body': 'Ведущее медицинское учреждение, обслуживающее Матрух, '
          'Новый Аламейн, Северное побережье, жителей, гостей и пациентов '
          'медицинского туризма.',
      'onb_s2_title': 'Многопрофильное превосходство',
      'onb_s2_body': 'Более 20 отделений объединяют специализированную помощь, '
          'включая кардиологию, нейрохирургию, неотложную помощь, радиологию, '
          'лечение инсульта и хирургию.',
      'onb_s3_title': 'Визуализация на основе ИИ',
      'onb_s3_body': 'Передовые технологии МРТ, КТ и катетеризации обеспечивают '
          'более быструю диагностику и более точные клинические решения.',
      'onb_s4_title': 'Качественная помощь',
      'onb_s4_body': 'Основана на безопасности, клиническом качестве, опыте '
          'пациента и надёжных стандартах здравоохранения на каждом этапе '
          'лечения.',
    },
    'zh': {
      'sign_in': '登录',
      'login_subtitle': '在阿拉曼示范医院获取您的医疗服务',
      'tab_id_password': '身份证和密码',
      'tab_qr': '二维码',
      'national_id': '身份证号',
      'national_id_hint': '30xxxxxxxxxxxxxxxxx',
      'password': '密码',
      'password_hint': '请输入密码',
      'qr_box_hint': '将相机对准患者的二维码腕带',
      'qr_token': '二维码令牌',
      'qr_token_hint': 'QR-XXXXXXXXXX',
      'scan_qr': '扫描二维码',
      'log_in': '登录',
      'footer': '阿拉曼示范医院 · AIU',
      'choose_language': '选择语言',
      'notif_care_advanced': '您的护理已进入',
      'notif_default': '通知',
      'notif_mark_all': '全部标为已读',
      'notif_empty_title': '没有新通知',
      'notif_empty_sub': '暂无通知。',
      'retry': '重试',
      'onb_about': '关于医院',
      'onb_next': '下一步',
      'onb_open_app': '打开患者应用',
      'onb_empowered': '由 AIU 提供支持',
      'onb_s1_title': '马特鲁省最大的医疗中心',
      'onb_s1_body': '领先的医疗目的地，服务于马特鲁、新阿拉曼、北海岸的居民、游客及医疗旅游患者。',
      'onb_s2_title': '多专科卓越',
      'onb_s2_body': '超过 20 个科室汇聚专业护理，包括心脏科、神经外科、急诊、放射科、卒中护理和外科。',
      'onb_s3_title': '人工智能影像',
      'onb_s3_body': '先进的 MRI、CT 和导管技术支持更快的诊断和更精确的临床决策。',
      'onb_s4_title': '以质量为驱动的护理',
      'onb_s4_body': '围绕安全、临床质量、患者体验和可信赖的医疗标准，贯穿每个护理阶段。',
    },
  };
}
