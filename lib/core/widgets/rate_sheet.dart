import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'star_row.dart';

/// The per-stage rating bottom sheet from the prototype.
///
/// Open it with the helper [RateSheet.show], which returns the chosen rating
/// (1..5) or null if the user dismissed it:
///
///   final stars = await RateSheet.show(context, stageTitle: 'Treatment');
///
/// Styling: navy heading + amber stars + blue primary "Submit" button.
class RateSheet extends StatefulWidget {
  final String stageTitle;

  const RateSheet({super.key, required this.stageTitle});

  /// Shows the sheet and resolves to the selected rating, or null.
  static Future<int?> show(BuildContext context, {required String stageTitle}) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RateSheet(stageTitle: stageTitle),
    );
  }

  @override
  State<RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<RateSheet> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Navy heading.
          Text(
            'Rate: ${widget.stageTitle}',
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Amber, tappable stars.
          StarRow(
            rating: _rating,
            size: 36,
            onTap: (value) => setState(() => _rating = value),
          ),
          const SizedBox(height: 20),
          // Blue primary button.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Disabled until the user picks at least one star.
              onPressed: _rating == 0
                  ? null
                  : () => Navigator.of(context).pop(_rating),
              child: const Text('Submit'),
            ),
          ),
          // TODO: add an optional comment field + send the rating to the repo.
        ],
      ),
    );
  }
}
