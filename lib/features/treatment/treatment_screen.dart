// [DATA] screen — owner: Lead.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/brand_bar.dart';
import 'treatment_vm.dart';

/// Treatment plan: the patient's current medicines and instructions.
class TreatmentScreen extends StatelessWidget {
  const TreatmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreatmentVm>();

    return Scaffold(
      appBar: const BrandBar(title: 'Treatment'),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (final m in vm.medicines)
                  ListTile(title: Text(m.name), subtitle: Text('${m.dose} • ${m.schedule}')),
                // TODO: build UI.
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: vm.load,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
