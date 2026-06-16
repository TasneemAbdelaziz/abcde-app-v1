// [STATIC] screen — owner: Beginner 1.
import 'package:flutter/material.dart';

import '../../core/widgets/brand_bar.dart';

/// Login screen (patient ID + password / OTP).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandBar(title: 'Login'),
      body: const Center(child: Text('Login')),
      // TODO: build UI.
    );
  }
}
