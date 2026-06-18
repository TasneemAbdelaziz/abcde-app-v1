import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/i18n/locale_controller.dart';
import 'core/network/api_client.dart';
import 'core/notifications/local_notifications.dart';
import 'core/notifications/notification_center.dart';
import 'core/repositories/auth_repository.dart';
import 'core/repositories/patient_api_repository.dart';
import 'core/repositories/patient_repository.dart';
import 'core/routing/routes.dart';
import 'core/storage/app_prefs.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/global_alert_overlay.dart';
import 'features/login/login_vm.dart';

// The shell holds the five tabs (Home Â· Visits Â· AI Advisor Â· Reports Â· Family)
// with a fixed bottom nav. Detail screens below are pushed on top.
import 'features/shell/main_shell.dart';

// Detail / non-tab screens.
import 'features/development/development_screen.dart';
import 'features/diagnosis/diagnosis_screen.dart';
import 'features/diagnosis/diagnosis_vm.dart';
import 'features/entertainment/entertainment_screen.dart';
import 'features/home/home_vm.dart';
import 'features/journey/journey_screen.dart';
import 'features/journey/journey_vm.dart';
import 'features/login/login_screen.dart';
import 'features/medicines/medicines_screen.dart';
import 'features/medicines/medicines_vm.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/notifications/notifications_vm.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/reports/reports_vm.dart';
import 'features/splash/splash_screen.dart';
import 'features/treatment/treatment_screen.dart';
import 'features/treatment/treatment_vm.dart';
import 'features/visits/visits_vm.dart';

/// Lets us navigate from outside the widget tree (e.g. when a system
/// notification is tapped).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load persisted flags (e.g. whether onboarding was already seen).
  await AppPrefs.init();
  // Set up local (heads-up) notifications. Tapping one opens the list.
  await LocalNotifications.init(
    onTap: (_) => rootNavigatorKey.currentState?.pushNamed(Routes.notifications),
  );
  runApp(const AlameinApp());
}

/// Root widget.
///
/// Dependency injection happens here with `provider`:
///   - ONE shared [PatientRepository] (created once).
///   - ONE ChangeNotifierProvider per [DATA] screen ViewModel.
///
/// When you add a new DATA screen, add its `*_vm` to this list and add its
/// screen to the `routes` map below. STATIC screens only need a route.
class AlameinApp extends StatelessWidget {
  const AlameinApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The single repository instance shared by every ViewModel.
    final repo = PatientRepository();

    // Networking + auth: one shared HTTP client; AuthRepository stores the
    // bearer token on it after a successful login.
    final api = ApiClient();
    final auth = AuthRepository(api);
    final patientApi = PatientApiRepository(api);

    // Language + the background notification poller (started after login).
    final locale = LocaleController();
    final notifications = NotificationCenter(patientApi, locale);

    return MultiProvider(
      providers: [
        // The data source. `.value` because we made it above.
        Provider<PatientRepository>.value(value: repo),
        Provider<ApiClient>.value(value: api),
        Provider<AuthRepository>.value(value: auth),
        Provider<PatientApiRepository>.value(value: patientApi),

        // App language (globe picker). Drives MaterialApp.locale below.
        ChangeNotifierProvider<LocaleController>.value(value: locale),

        // Background notification poller (live bell badge + heads-up banners).
        ChangeNotifierProvider<NotificationCenter>.value(value: notifications),

        // Login screen ViewModel (reads the shared AuthRepository).
        ChangeNotifierProvider(create: (_) => LoginVm(auth)),

        // Notifications list (reads the shared patient API repo).
        ChangeNotifierProvider(create: (_) => NotificationsVm(patientApi)),

        // One ViewModel per DATA screen. Each reads the shared repo.
        ChangeNotifierProvider(create: (_) => HomeVm(patientApi)),
        ChangeNotifierProvider(create: (_) => TreatmentVm(repo)),
        ChangeNotifierProvider(create: (_) => JourneyVm(repo)),
        ChangeNotifierProvider(create: (_) => ReportsVm(repo)),
        ChangeNotifierProvider(create: (_) => DiagnosisVm(repo)),
        ChangeNotifierProvider(create: (_) => MedicinesVm(repo)),
        ChangeNotifierProvider(create: (_) => VisitsVm(repo)),
        // TODO: register new ViewModels here.
      ],
      // ScreenUtil makes every .w/.h/.sp/.r scale from this 390Ã844 baseline,
      // so the UI looks right on any screen size.
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        // Consumer so MaterialApp rebuilds (and re-localizes) when the user
        // switches language from the globe picker.
        builder: (context, child) => Consumer<LocaleController>(
          builder: (context, localeCtrl, _) => MaterialApp(
        title: 'Alamein Model Hospital — Patient Portal',
        theme: AppTheme.light(),
        debugShowCheckedModeBanner: false,
        // So a tapped notification can navigate from outside the widget tree.
        navigatorKey: rootNavigatorKey,
        // Localization: current language + the delegates that translate
        // built-in Material/Cupertino widgets and set text direction (RTL for
        // Arabic). Supported languages come from LocaleController.
        locale: localeCtrl.locale,
        supportedLocales: LocaleController.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Splash (logo) â onboarding carousel â login â home.
        initialRoute: Routes.splash,
        //     initialRoute: Routes.onboarding,
        // Track the top route (so the alert FAB can hide on login/onboarding)...
        navigatorObservers: [GlobalAlert.observer],
        // ...and overlay the floating "Call your doctor" button on every screen.
        builder: GlobalAlert.wrap,
        routes: {
          // The five tabs all open the shell on the matching tab. The shell's
          // fixed bottom nav handles switching between them after that.
          Routes.home: (_) => const MainShell(initialIndex: 0),
          Routes.visits: (_) => const MainShell(initialIndex: 1),
          Routes.aiAdvisor: (_) => const MainShell(initialIndex: 2),
          Routes.reports: (_) => const MainShell(initialIndex: 3),
          Routes.family: (_) => const MainShell(initialIndex: 4),

          // Splash + onboarding (the entry flow).
          Routes.splash: (_) => const SplashScreen(),

          // Detail screens (pushed on top of the shell).
          Routes.treatment: (_) => const TreatmentScreen(),
          Routes.journey: (_) => const JourneyScreen(),
          Routes.onboarding: (_) => const OnboardingScreen(),
          Routes.login: (_) => const LoginScreen(),
          Routes.notifications: (_) => const NotificationsScreen(),
          Routes.profile: (_) => const ProfileScreen(),
          Routes.entertainment: (_) => const EntertainmentScreen(),
          Routes.development: (_) => const DevelopmentScreen(),
          Routes.diagnosis: (_) => const DiagnosisScreen(),
          Routes.medicines: (_) => const MedicinesScreen(),
        },
      ),
      ),
      ),
    );
  }
}
