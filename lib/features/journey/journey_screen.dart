// [DATA] screen — owner: Lead. Also demonstrates the RateSheet.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/brand_bar.dart';
import '../../core/widgets/rate_sheet.dart';
import '../../core/widgets/star_row.dart';
import 'journey_vm.dart';

/// Treatment journey: a timeline of stages the patient can rate.
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JourneyVm>();

    return Scaffold(
      appBar: const BrandBar(title: 'Journey'),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (final stage in vm.stages)
                  ListTile(
                    title: Text(stage.title),
                    subtitle: StarRow(rating: stage.rating, size: 18),
                    trailing: TextButton(
                      onPressed: () async {
                        final rating = await RateSheet.show(context, stageTitle: stage.title);
                        if (rating != null) vm.rateStage(stage.id, rating);
                      },
                      child: const Text('Rate'),
                    ),
                  ),
                // TODO: build UI (proper timeline visuals).
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: vm.load,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
