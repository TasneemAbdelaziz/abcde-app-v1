# Alamein Model Hospital — Patient Portal

A Flutter app for hospital patients (multi-language: **EN / AR / RU / ZH**).
This repo is currently a **scaffold**: folder + file structure with stubs and
`// TODO` markers. A 3-person team fills in the screens.

## Architecture (read this first)

**MVVM, beginner-friendly.**

- **State management:** `ChangeNotifier` only. **Do NOT use Riverpod or Bloc.**
- **Dependency injection:** the `provider` package (set up in `lib/main.dart`).
- **Feature-first** folders: each screen lives in its own folder under `lib/features/`.
- **Data layer:** ONE simple `PatientRepository` that returns hardcoded mock data.
  (It will be split into an interface + API implementation when the backend exists.)

Two kinds of screens:

| Type        | Widget              | Has a ViewModel? | How it gets data |
|-------------|---------------------|------------------|------------------|
| **[STATIC]**| `StatelessWidget`   | No               | None — fixed UI  |
| **[DATA]**  | `StatelessWidget`   | Yes (`*_vm.dart`)| `context.watch<XxxVm>()` |

> **Golden rule:** widgets only *display*. All data and logic live in the
> ViewModel or the repository. A screen never calls the repository directly.

## Folder map

```
lib/
├─ main.dart                 # MaterialApp + MultiProvider + temporary Dev Menu
├─ core/
│  ├─ theme/      app_theme.dart      # colors + ThemeData (Noto Sans)
│  ├─ models/     patient.dart  visit_stage.dart  report.dart  medicine.dart
│  ├─ routing/    routes.dart         # route name constants
│  ├─ l10n/       strings.dart        # Map for EN/AR/RU/ZH + isRtl() helper
│  ├─ repositories/ patient_repository.dart   # mock data
│  └─ widgets/    brand_bar.dart  star_row.dart  rate_sheet.dart
└─ features/
   ├─ _template/  static_screen_template.dart  data_screen_template.dart  template_vm.dart
   ├─ home/       home_screen.dart        home_vm.dart        [DATA]
   ├─ treatment/  treatment_screen.dart   treatment_vm.dart   [DATA]
   ├─ journey/    journey_screen.dart     journey_vm.dart     [DATA]
   ├─ reports/    reports_screen.dart     reports_vm.dart     [DATA]
   ├─ onboarding/ onboarding_screen.dart                      [STATIC]
   ├─ login/      login_screen.dart                           [STATIC]
   ├─ notifications/ notifications_screen.dart                [STATIC]
   ├─ profile/    profile_screen.dart                         [STATIC]
   ├─ entertainment/ entertainment_screen.dart                [STATIC]
   ├─ development/ development_screen.dart                     [STATIC]
   ├─ family/     family_screen.dart                          [STATIC]
   ├─ ai_advisor/ ai_advisor_screen.dart                      [STATIC]
   ├─ diagnosis/  diagnosis_screen.dart   diagnosis_vm.dart   [DATA]
   ├─ medicines/  medicines_screen.dart   medicines_vm.dart   [DATA]
   └─ visits/     visits_screen.dart      visits_vm.dart      [DATA]
```

## Who owns what

| Person                  | Screens (type) |
|-------------------------|----------------|
| **Lead** (experienced)  | All of `core/` · `home` [DATA] · `treatment` [DATA] · `journey` [DATA] (owns `core/widgets/rate_sheet.dart`) · `reports` [DATA] · `_template` |
| **Beginner 1**          | `onboarding` [STATIC] · `login` [STATIC] · `notifications` [STATIC] · `profile` [STATIC] |
| **Beginner 2**          | `entertainment` [STATIC] · `development` [STATIC] · `family` [STATIC] · `ai_advisor` [STATIC] · `diagnosis` [DATA] · `medicines` [DATA] · `visits` [DATA] |

## Screen recipe — "COPY ME, 4 steps"

Start from the templates in `lib/features/_template/`.

1. Make a new folder under `features/`.
2. Copy the matching template and rename the class + file
   (static → one file; data → the screen **and** the `_vm.dart`).
3. **STATIC** → just build the UI.
   **DATA** → in the copied `_vm.dart`, change which `PatientRepository` method
   `load()` calls; read it in the screen with `context.watch<XxxVm>()`.
4. Add the route in `core/routing/routes.dart` **and** register the screen
   (and the VM, for DATA screens) in `lib/main.dart`.

## Running

```bash
flutter pub get
flutter run        # opens on the Dev Menu — tap a screen to open it
flutter analyze    # must be clean before you open a PR
```

The app opens on a **temporary Dev Menu** listing every screen, so each
developer can jump straight to the one they are building.

## Git rules

- **One branch per feature** (e.g. `feature/login`, `feature/medicines`).
- All merges go through a **Pull Request reviewed by the Lead**.
- **Nobody edits `core/` except the Lead.** Need a change there? Ask the Lead.
- `flutter analyze` must pass with **zero errors** before opening a PR.
- Keep files short and readable — beginners are reading this code too.
