// [STATIC] screen — owner: Beginner 2.
import 'package:flutter/material.dart';

import '../../core/widgets/brand_bar.dart';

/// AI health advisor chat (placeholder for now).
class AiAdvisorScreen extends StatelessWidget {
  const AiAdvisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandBar(title: 'AI Advisor'),
      body: const Center(child: Text('AI Advisor')),
      // TODO: build UI.
    );
  }
}
