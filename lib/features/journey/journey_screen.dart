// [DATA] screen — owner: Lead. Also demonstrates the RateSheet.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/brand_bar.dart';
import '../../core/widgets/rate_sheet.dart';
import '../../core/widgets/star_row.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/visit_stage.dart';
import 'journey_vm.dart';
import 'journey_header_section.dart';

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
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                JourneyHeaderSection(header: vm.header),
                const SizedBox(height: 10),
                for (final stage in vm.stages)
                  _JourneyStageTile(
                    stage: stage,
                    onRate: () async {
                      final rating = await RateSheet.show(
                        context,
                        stageTitle: stage.title,
                      );
                      if (rating != null) vm.rateStage(stage.id, rating);
                    },
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

class _JourneyStageTile extends StatelessWidget {
  final VisitStage stage;
  final VoidCallback onRate;

  const _JourneyStageTile({required this.stage, required this.onRate});

  Color get _dotColor {
    switch (stage.status) {
      case 'done':
        return AppColors.green;
      case 'current':
        return AppColors.blue;
      default:
        return AppColors.border2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Column(
            children: [
              CircleAvatar(radius: 6, backgroundColor: _dotColor),
              Container(width: 2, height: 60, color: AppColors.border2),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        stage.status == 'current'
                            ? 'Happening now'
                            : stage.status == 'done'
                            ? 'Completed'
                            : 'Upcoming',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      const Spacer(),
                      if (stage.status != 'done')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            stage.status == 'current'
                                ? 'Happening now'
                                : 'Upcoming',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  StarRow(rating: stage.rating, size: 18),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: onRate,
                    child: const Text('Rate this stage'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
