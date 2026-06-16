// [STATIC] screen — owner: Beginner 1.
import 'package:flutter/material.dart';

import '../../core/widgets/brand_bar.dart';

/// Patient profile and settings (language, contact info).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandBar(title: 'Profile'),
      body: const Center(child: Text('Profile')),
      // TODO: build UI.
    );
  }
}
