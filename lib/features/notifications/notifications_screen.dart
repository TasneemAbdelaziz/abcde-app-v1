// [STATIC] screen — owner: Beginner 1.
import 'package:flutter/material.dart';

import '../../core/widgets/brand_bar.dart';

/// Notifications / alerts list.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandBar(title: 'Notifications'),
      body: const Center(child: Text('Notifications')),
      // TODO: build UI.
    );
  }
}
