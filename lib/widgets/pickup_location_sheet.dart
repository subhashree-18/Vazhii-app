import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class PickupLocationSheet extends StatefulWidget {
  final String currentLocation;
  final ValueChanged<String> onSelected;

  const PickupLocationSheet({
    super.key,
    required this.currentLocation,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentLocation,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PickupLocationSheet(
        currentLocation: currentLocation,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<PickupLocationSheet> createState() => _PickupLocationSheetState();
}

class _PickupLocationSheetState extends State<PickupLocationSheet> {
  late final TextEditingController _controller;
  final List<String> _popularPickups = const [
    'Chennai (Airport / Central / Koyambedu)',
    'Coimbatore (Railway Station / Airport)',
    'Madurai (Meenakshi / Mattuthavani)',
    'Tiruchirappalli (Trichy Junction / Airport)',
    'Salem (New Bus Stand / Junction)',
    'Erode (Central)',
    'Tirunelveli (Junction)',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentLocation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
            'Change Pickup Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Where should the taxi pick you up?',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.my_location, color: AppColors.primary),
              hintText: 'Enter pickup address or city',
              suffixIcon: IconButton(
                icon: const Icon(Icons.check_circle, color: AppColors.primary),
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    widget.onSelected(_controller.text.trim());
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                widget.onSelected(value.trim());
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(height: 18),
          const Text(
            'Suggested Starting Hubs',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularPickups.map((hub) {
              final isSelected = widget.currentLocation == hub;
              return ActionChip(
                backgroundColor:
                    isSelected ? AppColors.primaryLight : AppColors.surfaceVariant,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                ),
                label: Text(
                  hub.split('(').first.trim(),
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                onPressed: () {
                  widget.onSelected(hub);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

