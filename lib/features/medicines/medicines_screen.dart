// [DATA] screen — owner: Beginner 2.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/brand_bar.dart';
import 'medicines_vm.dart';

/// List of prescribed medicines with dose and schedule.
class MedicinesScreen extends StatelessWidget {
  const MedicinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MedicinesVm>();

    return Scaffold(
      appBar: const BrandBar(title: 'Medicines'),
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
