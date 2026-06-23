// [STATIC] screen — owner: Beginner 1.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/widgets/brand_bar.dart';

/// Patient profile and settings (language, contact info).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandBar(title: context.watch<LocaleController>().t('title_profile')),
      body: const Center(child: Text('Profile')),
      // TODO: build UI.
    );
  }
}
