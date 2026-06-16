// [STATIC] screen — owner: Beginner 1.
import 'package:flutter/material.dart';

import '../../core/widgets/brand_bar.dart';

/// Onboarding / welcome carousel shown on first launch.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandBar(title: 'Onboarding'),
      body: const Center(child: Text('Onboarding')),
      // TODO: build UI.
    );
  }
}
