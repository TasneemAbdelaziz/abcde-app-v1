// [STATIC] screen — owner: Beginner 2.
import 'package:flutter/material.dart';

import '../../core/widgets/brand_bar.dart';

/// Family / visitor information and contacts.
class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandBar(title: 'Family'),
      body: const Center(child: Text('Family')),
      // TODO: build UI.
    );
  }
}
