// [STATIC] screen — owner: Beginner 2.
import 'package:flutter/material.dart';

import '../../core/widgets/brand_bar.dart';

/// Patient education / development resources.
class DevelopmentScreen extends StatelessWidget {
  const DevelopmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandBar(title: 'Development'),
      body: const Center(child: Text('Development')),
      // TODO: build UI.
    );
  }
}
