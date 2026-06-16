// [DATA] screen — owner: Beginner 2.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/brand_bar.dart';
import 'diagnosis_vm.dart';

/// Current diagnosis and findings.
class DiagnosisScreen extends StatelessWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiagnosisVm>();

    return Scaffold(
      appBar: const BrandBar(title: 'Diagnosis'),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (final f in vm.findings)
                  ListTile(leading: const Icon(Icons.medical_information), title: Text(f)),
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
