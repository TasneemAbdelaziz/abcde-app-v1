import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/repositories/patient_repository.dart';
import 'core/routing/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/global_alert_overlay.dart';

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
import 'features/onboarding/onboarding_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/reports/reports_vm.dart';
import 'features/treatment/treatment_screen.dart';
import 'features/treatment/treatment_vm.dart';
import 'features/visits/visits_vm.dart';

void main() {
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

    return MultiProvider(
      providers: [
        // The data source. `.value` because we made it above.
        Provider<PatientRepository>.value(value: repo),

        // One ViewModel per DATA screen. Each reads the shared repo.
        ChangeNotifierProvider(create: (_) => HomeVm(repo)),
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
        builder: (context, child) => MaterialApp(
        title: 'Alamein Model Hospital — Patient Portal',
        theme: AppTheme.light(),
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.treatment, // TODO: change to Routes.onboarding for production.
        // Track the top route (so the alert FAB cٌan hide on login/onboarding)...
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
    );
  }
}
