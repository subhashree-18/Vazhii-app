import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class DurationPickerSheet extends StatelessWidget {
  final int currentDays;
  final ValueChanged<int> onDaysSelected;

  const DurationPickerSheet({
    super.key,
    required this.currentDays,
    required this.onDaysSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required int currentDays,
    required ValueChanged<int> onDaysSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DurationPickerSheet(
        currentDays: currentDays,
        onDaysSelected: onDaysSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Select Travel Duration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose how many days you need the taxi and driver.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.remove),
                color: AppColors.primary,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                ),
                onPressed: currentDays > 1
                    ? () {
                        onDaysSelected(currentDays - 1);
                        Navigator.pop(context);
                      }
                    : null,
              ),
              const SizedBox(width: 24),
              Text(
                '$currentDays ${currentDays == 1 ? "Day" : "Days"}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 24),
              IconButton.filledTonal(
                icon: const Icon(Icons.add),
                color: AppColors.primary,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                ),
                onPressed: currentDays < 14
                    ? () {
                        onDaysSelected(currentDays + 1);
                        Navigator.pop(context);
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Quick Select',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [1, 2, 3, 4, 5, 7].map((days) {
              final isSelected = currentDays == days;
              return ChoiceChip(
                label: Text('$days ${days == 1 ? "Day" : "Days"}'),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceVariant,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                onSelected: (_) {
                  onDaysSelected(days);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

