// [STATIC] screen — owner: Beginner 2.
import 'package:flutter/material.dart';

import '../../core/widgets/brand_bar.dart';

/// In-room entertainment (TV, music, games).
class EntertainmentScreen extends StatelessWidget {
  const EntertainmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandBar(title: 'Entertainment'),
      body: const Center(child: Text('Entertainment')),
      // TODO: build UI.
    );
  }
}

