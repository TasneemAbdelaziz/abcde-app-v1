// ============================================================================
// COPY ME — 4 steps (for a [STATIC] screen)
// ----------------------------------------------------------------------------
// 1. Make a new folder under features/ (e.g. features/login/).
// 2. Copy this file there and rename it (e.g. login_screen.dart).
//    Rename the class too (StaticScreenTemplate -> LoginScreen).
// 3. STATIC means: just build the UI. No ViewModel, no repository.
// 4. Add the route in core/routing/routes.dart, then register the screen in
//    the `routes` map in main.dart.
//
// GOLDEN RULE: widgets only DISPLAY. A static screen shows fixed UI; if you
// need data or logic, it is NOT static — use the data template instead.
// ============================================================================

import 'package:flutter/material.dart';

import '../../core/widgets/brand_bar.dart';

/// Example STATIC screen: a StatelessWidget with no ViewModel.
class StaticScreenTemplate extends StatelessWidget {
  const StaticScreenTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandBar(title: 'Static Template'),
      body: const Center(
        child: Text('Static screen — build your UI here.'),
        // TODO: build UI.
      ),
    );
  }
}
