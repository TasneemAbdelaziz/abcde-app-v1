/// Route name constants for every screen in the app.
///
/// Use these constants everywhere instead of typing route strings by hand,
/// e.g. `Navigator.pushNamed(context, Routes.home)`.
///
/// COPY ME: when you add a new screen, add its constant here AND register the
/// screen in the `routes` map inside main.dart.
class Routes {
  Routes._(); // no instances

  // Lead (experienced) — DATA screens.
  static const String home = '/home';
  static const String treatment = '/treatment';
  static const String journey = '/journey';
  static const String reports = '/reports';

  // Beginner 1 — STATIC screens.
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Beginner 2 — STATIC + DATA screens.
  static const String entertainment = '/entertainment';
  static const String development = '/development';
  static const String family = '/family';
  static const String aiAdvisor = '/ai-advisor';
  static const String diagnosis = '/diagnosis';
  static const String medicines = '/medicines';
  static const String visits = '/visits';
  static const String rating = '/rating';
  static const String alert = '/alert';
}
