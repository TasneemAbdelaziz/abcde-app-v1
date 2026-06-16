// [DATA] screen — owner: Lead.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/brand_bar.dart';
import 'reports_vm.dart';

/// Medical reports and lab results.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportsVm>();

    return Scaffold(
      appBar: const BrandBar(title: 'Reports'),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (final r in vm.reports)
                  ListTile(title: Text(r.title), subtitle: Text('${r.type} • ${r.date}')),
                // TODO: build UI.
              ],
            ),

    );
  }
}
