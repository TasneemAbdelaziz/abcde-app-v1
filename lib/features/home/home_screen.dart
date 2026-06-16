// [DATA] screen — owner: Lead.
//
// Empty for now. The BrandBar (top logos) and the bottom nav are fixed by the
// shell, so just build the Home content here, reading data from HomeVm via
// context.watch.
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: BrandBar(),
      body: Center(
        child: Text('// TODO: build Home UI'),
      ),
    );
  }
}
