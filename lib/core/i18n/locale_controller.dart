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
      // Bottom nav
      'nav_home': 'Home',
      'nav_visits': 'Visits',
      'nav_ai': 'AI Advisor',
      'nav_reports': 'Reports',
      'nav_family': 'Family',
      // Screen titles
      'title_visits': 'My Visits',
      'title_diagnosis': 'Diagnosis',
      'title_medicines': 'My Medicines',
      'title_notifications': 'Notifications',
      'title_profile': 'Profile',
      'title_care_journey': 'Care Journey',
      // Home
      'greet_morning': 'Good morning',
      'greet_afternoon': 'Good afternoon',
      'greet_evening': 'Good evening',
      'home_vitals': 'VITAL READINGS',
      'home_my_health': 'MY HEALTH',
      'home_no_vitals': 'No recent vital readings.',
      'care_journey': 'Care Journey',
      'view': 'View',
      'admitted': 'Admitted',
      'doctor': 'Doctor',
      'not_in_visit': 'Not in an active visit',
      'stage': 'Stage',
      'of': 'of',
      'tile_diagnosis': 'Diagnosis',
      'tile_treatment': 'Treatment Plan',
      'tile_rating': 'Rating',
      'tile_development': 'Development',
      'tile_entertainment': 'Entertainment',
      // Visits
      'visit_active': 'Active',
      'visit_completed': 'Completed',
      'in_progress': 'in progress',
      'no_visits': 'No visits yet.',
      'visits_error': 'Could not load visits.',
      // Medicines
      'meds_none': 'No prescribed medicines yet.',
      'meds_error': 'Could not load medicines.',
      // Diagnosis
      'dx_current': 'Current diagnosis',
      'dx_case': 'YOUR CASE EXPLAINED',
      'dx_means': 'WHAT THIS MEANS',
      'dx_prevent': 'HOW TO PREVENT IT FROM WORSENING',
      'dx_error': 'Could not load the diagnosis.',
      // More screen titles
      'title_reports': 'Reports',
      'title_treatment': 'Treatment Plan',
      'title_development': 'Development',
      'title_journey': 'Journey',
      'title_entertainment': 'Learn & Relax',
      'title_family': 'Family Members',
      'title_ai': 'AI Advisor',
      // Reports
      'records': 'RECORDS',
      'reports_subtitle': 'Recent reports, lab results, and medical documents.',
      'tab_health': 'Health',
      'tab_financial': 'Financial',
      'pay_now': 'Pay Now',
      // Treatment
      'tx_surgery': 'YOUR SURGERY EXPLAINED',
      'tx_after': 'AFTER YOUR SURGERY',
      'tx_timeline': "TODAY'S MEDICINE TIMELINE",
      'tx_goals': "TODAY'S GOALS",
      'tx_upcoming': 'UPCOMING',
      'my_medicines': 'My Medicines',
      // Development
      'dev_area': 'Area of suggestion',
      'dev_suggestion': 'Your suggestion',
      'dev_submit': 'Submit Suggestion',
      'dev_thanks': 'Thank you!',
      // Journey
      'happening_now': 'Happening now',
      'rate_stage': 'Rate this stage',
      // Entertainment
      'tab_learn': 'Learn',
      'tab_relax': 'Relax',
      'games': 'GAMES',
      'music': 'MUSIC',
      // Family
      'family_manage': 'Manage who follows your care',
      'add_manually': 'Add Manually',
      'privacy_controls': 'PRIVACY CONTROLS',
      'what_family_sees': 'What family can see',
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
      // Bottom nav
      'nav_home': 'الرئيسية',
      'nav_visits': 'الزيارات',
      'nav_ai': 'المساعد الذكي',
      'nav_reports': 'التقارير',
      'nav_family': 'العائلة',
      // Screen titles
      'title_visits': 'زياراتي',
      'title_diagnosis': 'التشخيص',
      'title_medicines': 'أدويتي',
      'title_notifications': 'الإشعارات',
      'title_profile': 'الملف الشخصي',
      'title_care_journey': 'رحلة الرعاية',
      // Home
      'greet_morning': 'صباح الخير',
      'greet_afternoon': 'مساء الخير',
      'greet_evening': 'مساء الخير',
      'home_vitals': 'القياسات الحيوية',
      'home_my_health': 'صحتي',
      'home_no_vitals': 'لا توجد قياسات حيوية حديثة.',
      'care_journey': 'رحلة الرعاية',
      'view': 'عرض',
      'admitted': 'تاريخ الدخول',
      'doctor': 'الطبيب',
      'not_in_visit': 'لا توجد زيارة نشطة',
      'stage': 'المرحلة',
      'of': 'من',
      'tile_diagnosis': 'التشخيص',
      'tile_treatment': 'خطة العلاج',
      'tile_rating': 'التقييم',
      'tile_development': 'التطوير',
      'tile_entertainment': 'الترفيه',
      // Visits
      'visit_active': 'نشطة',
      'visit_completed': 'مكتملة',
      'in_progress': 'قيد التنفيذ',
      'no_visits': 'لا توجد زيارات بعد.',
      'visits_error': 'تعذّر تحميل الزيارات.',
      // Medicines
      'meds_none': 'لا توجد أدوية موصوفة بعد.',
      'meds_error': 'تعذّر تحميل الأدوية.',
      // Diagnosis
      'dx_current': 'التشخيص الحالي',
      'dx_case': 'شرح حالتك',
      'dx_means': 'ماذا يعني هذا',
      'dx_prevent': 'كيف تمنع تفاقمها',
      'dx_error': 'تعذّر تحميل التشخيص.',
      // More screen titles
      'title_reports': 'التقارير',
      'title_treatment': 'خطة العلاج',
      'title_development': 'التطوير',
      'title_journey': 'الرحلة',
      'title_entertainment': 'تعلّم واسترخِ',
      'title_family': 'أفراد العائلة',
      'title_ai': 'المساعد الذكي',
      // Reports
      'records': 'السجلات',
      'reports_subtitle': 'أحدث التقارير ونتائج التحاليل والمستندات الطبية.',
      'tab_health': 'صحية',
      'tab_financial': 'مالية',
      'pay_now': 'ادفع الآن',
      // Treatment
      'tx_surgery': 'شرح عمليتك',
      'tx_after': 'بعد العملية',
      'tx_timeline': 'مواعيد أدوية اليوم',
      'tx_goals': 'أهداف اليوم',
      'tx_upcoming': 'القادم',
      'my_medicines': 'أدويتي',
      // Development
      'dev_area': 'مجال الاقتراح',
      'dev_suggestion': 'اقتراحك',
      'dev_submit': 'إرسال الاقتراح',
      'dev_thanks': 'شكرًا لك!',
      // Journey
      'happening_now': 'يحدث الآن',
      'rate_stage': 'قيّم هذه المرحلة',
      // Entertainment
      'tab_learn': 'تعلّم',
      'tab_relax': 'استرخِ',
      'games': 'ألعاب',
      'music': 'موسيقى',
      // Family
      'family_manage': 'تحكّم بمن يتابع رعايتك',
      'add_manually': 'إضافة يدويًا',
      'privacy_controls': 'إعدادات الخصوصية',
      'what_family_sees': 'ما يمكن للعائلة رؤيته',
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
      // Bottom nav
      'nav_home': 'Главная',
      'nav_visits': 'Визиты',
      'nav_ai': 'ИИ-помощник',
      'nav_reports': 'Отчёты',
      'nav_family': 'Семья',
      // Screen titles
      'title_visits': 'Мои визиты',
      'title_diagnosis': 'Диагноз',
      'title_medicines': 'Мои лекарства',
      'title_notifications': 'Уведомления',
      'title_profile': 'Профиль',
      'title_care_journey': 'Путь лечения',
      // Home
      'greet_morning': 'Доброе утро',
      'greet_afternoon': 'Добрый день',
      'greet_evening': 'Добрый вечер',
      'home_vitals': 'ПОКАЗАТЕЛИ',
      'home_my_health': 'МОЁ ЗДОРОВЬЕ',
      'home_no_vitals': 'Нет недавних показателей.',
      'care_journey': 'Путь лечения',
      'view': 'Открыть',
      'admitted': 'Поступление',
      'doctor': 'Врач',
      'not_in_visit': 'Нет активного визита',
      'stage': 'Этап',
      'of': 'из',
      'tile_diagnosis': 'Диагноз',
      'tile_treatment': 'План лечения',
      'tile_rating': 'Оценка',
      'tile_development': 'Развитие',
      'tile_entertainment': 'Развлечения',
      // Visits
      'visit_active': 'Активный',
      'visit_completed': 'Завершён',
      'in_progress': 'в процессе',
      'no_visits': 'Визитов пока нет.',
      'visits_error': 'Не удалось загрузить визиты.',
      // Medicines
      'meds_none': 'Назначенных лекарств пока нет.',
      'meds_error': 'Не удалось загрузить лекарства.',
      // Diagnosis
      'dx_current': 'Текущий диагноз',
      'dx_case': 'РАЗЪЯСНЕНИЕ ВАШЕГО СЛУЧАЯ',
      'dx_means': 'ЧТО ЭТО ЗНАЧИТ',
      'dx_prevent': 'КАК ПРЕДОТВРАТИТЬ УХУДШЕНИЕ',
      'dx_error': 'Не удалось загрузить диагноз.',
      // More screen titles
      'title_reports': 'Отчёты',
      'title_treatment': 'План лечения',
      'title_development': 'Развитие',
      'title_journey': 'Путь',
      'title_entertainment': 'Учись и отдыхай',
      'title_family': 'Члены семьи',
      'title_ai': 'ИИ-помощник',
      // Reports
      'records': 'ЗАПИСИ',
      'reports_subtitle': 'Недавние отчёты, результаты анализов и документы.',
      'tab_health': 'Здоровье',
      'tab_financial': 'Финансы',
      'pay_now': 'Оплатить',
      // Treatment
      'tx_surgery': 'РАЗЪЯСНЕНИЕ ОПЕРАЦИИ',
      'tx_after': 'ПОСЛЕ ОПЕРАЦИИ',
      'tx_timeline': 'ГРАФИК ЛЕКАРСТВ НА СЕГОДНЯ',
      'tx_goals': 'ЦЕЛИ НА СЕГОДНЯ',
      'tx_upcoming': 'ПРЕДСТОЯЩЕЕ',
      'my_medicines': 'Мои лекарства',
      // Development
      'dev_area': 'Область предложения',
      'dev_suggestion': 'Ваше предложение',
      'dev_submit': 'Отправить предложение',
      'dev_thanks': 'Спасибо!',
      // Journey
      'happening_now': 'Происходит сейчас',
      'rate_stage': 'Оценить этап',
      // Entertainment
      'tab_learn': 'Учиться',
      'tab_relax': 'Отдых',
      'games': 'ИГРЫ',
      'music': 'МУЗЫКА',
      // Family
      'family_manage': 'Управляйте, кто следит за вашим лечением',
      'add_manually': 'Добавить вручную',
      'privacy_controls': 'НАСТРОЙКИ КОНФИДЕНЦИАЛЬНОСТИ',
      'what_family_sees': 'Что видит семья',
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
      // Bottom nav
      'nav_home': '主页',
      'nav_visits': '就诊',
      'nav_ai': 'AI 助手',
      'nav_reports': '报告',
      'nav_family': '家人',
      // Screen titles
      'title_visits': '我的就诊',
      'title_diagnosis': '诊断',
      'title_medicines': '我的药物',
      'title_notifications': '通知',
      'title_profile': '个人资料',
      'title_care_journey': '护理历程',
      // Home
      'greet_morning': '早上好',
      'greet_afternoon': '下午好',
      'greet_evening': '晚上好',
      'home_vitals': '生命体征',
      'home_my_health': '我的健康',
      'home_no_vitals': '暂无最近的生命体征。',
      'care_journey': '护理历程',
      'view': '查看',
      'admitted': '入院',
      'doctor': '医生',
      'not_in_visit': '没有进行中的就诊',
      'stage': '阶段',
      'of': '/',
      'tile_diagnosis': '诊断',
      'tile_treatment': '治疗方案',
      'tile_rating': '评分',
      'tile_development': '发展',
      'tile_entertainment': '娱乐',
      // Visits
      'visit_active': '进行中',
      'visit_completed': '已完成',
      'in_progress': '进行中',
      'no_visits': '暂无就诊记录。',
      'visits_error': '无法加载就诊记录。',
      // Medicines
      'meds_none': '暂无处方药物。',
      'meds_error': '无法加载药物。',
      // Diagnosis
      'dx_current': '当前诊断',
      'dx_case': '您的病例说明',
      'dx_means': '这意味着什么',
      'dx_prevent': '如何防止恶化',
      'dx_error': '无法加载诊断。',
      // More screen titles
      'title_reports': '报告',
      'title_treatment': '治疗方案',
      'title_development': '发展',
      'title_journey': '历程',
      'title_entertainment': '学习与放松',
      'title_family': '家庭成员',
      'title_ai': 'AI 助手',
      // Reports
      'records': '记录',
      'reports_subtitle': '最近的报告、化验结果和医疗文件。',
      'tab_health': '健康',
      'tab_financial': '财务',
      'pay_now': '立即支付',
      // Treatment
      'tx_surgery': '您的手术说明',
      'tx_after': '术后须知',
      'tx_timeline': '今日用药时间表',
      'tx_goals': '今日目标',
      'tx_upcoming': '即将到来',
      'my_medicines': '我的药物',
      // Development
      'dev_area': '建议领域',
      'dev_suggestion': '您的建议',
      'dev_submit': '提交建议',
      'dev_thanks': '谢谢！',
      // Journey
      'happening_now': '正在进行',
      'rate_stage': '评价此阶段',
      // Entertainment
      'tab_learn': '学习',
      'tab_relax': '放松',
      'games': '游戏',
      'music': '音乐',
      // Family
      'family_manage': '管理关注您护理的人',
      'add_manually': '手动添加',
      'privacy_controls': '隐私控制',
      'what_family_sees': '家人可见内容',
    },
  };
}
