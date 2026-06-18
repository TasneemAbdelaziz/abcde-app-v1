import '../i18n/locale_controller.dart';
import '../models/app_notification.dart';
import '../models/visit.dart';

/// Builds a notification's display title in the app's current language from its
/// structured [AppNotification.type] / [AppNotification.data], falling back to
/// the server title. The backend stores titles in the patient's saved language,
/// so rendering known types ourselves honours the language picked in the app.
String notificationTitle(AppNotification n, LocaleController loc) {
  if (n.type == 'stage_change') {
    final stage = (n.data['stage'] ?? '').toString();
    if (stage.isNotEmpty) {
      return '${loc.t('notif_care_advanced')}: ${Visit.prettyStage(stage)}';
    }
  }
  if (n.title.isNotEmpty) return n.title;
  return loc.t('notif_default');
}
