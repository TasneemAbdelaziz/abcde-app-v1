// ============================================================================
// COPY ME — 4 steps (for a [DATA] screen)
// ----------------------------------------------------------------------------
// 1. Make a new folder under features/ (e.g. features/medicines/).
// 2. Copy BOTH this file and template_vm.dart there, and rename them
//    (medicines_screen.dart + medicines_vm.dart). Rename the classes too.
// 3. In the _vm.dart, change which repository method load() calls.
// 4. Add the route in core/routing/routes.dart, then register BOTH the screen
//    and the VM (as a ChangeNotifierProvider) in main.dart.
//
// GOLDEN RULE: widgets only DISPLAY; all data/logic lives in the ViewModel or
// repository. Never call the repository from inside a screen.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/brand_bar.dart';
import 'template_vm.dart';

/// Example DATA screen: a StatelessWidget that reads a ChangeNotifier ViewModel.
class DataScreenTemplate extends StatelessWidget {
  const DataScreenTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    // `watch` rebuilds this widget whenever the VM calls notifyListeners().
    final vm = context.watch<TemplateVm>();

    return Scaffold(
      appBar: const BrandBar(title: 'Data Template'),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (final item in vm.items) ListTile(title: Text(item)),
              ],
            ),
      // Trigger the first load. (For real screens, prefer loading in the VM
      // constructor or via a one-time init — this button keeps the demo simple.)
      floatingActionButton: FloatingActionButton(
        onPressed: vm.load,
        child: const Icon(Icons.refresh),
      ),
      // TODO: build the real UI from vm's data.
    );
  }
}
