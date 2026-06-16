// [DATA] screen — owner: Beginner 2.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/brand_bar.dart';
import 'visits_vm.dart';

/// Past and upcoming hospital visits.
class VisitsScreen extends StatelessWidget {
  const VisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitsVm>();

    return Scaffold(
      appBar: const BrandBar(title: 'Visits'),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (final v in vm.visits)
                  ListTile(leading: const Icon(Icons.event), title: Text(v)),
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
