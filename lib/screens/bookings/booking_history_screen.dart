import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import 'widgets/booking_history_card.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = const [
    'All',
    'Awaiting',
    'Confirmed',
    'Cancellation Requested',
    'Cancelled',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      // Subscribe to real-time updates from Firestore
      context.read<BookingProvider>().subscribeToUserBookings(auth.currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final booking = context.watch<BookingProvider>();

    final filteredList = booking.userBookings.where((b) {
      final status = b.bookingStatus.toLowerCase();
      if (_selectedFilter == 'Awaiting') {
        return status == 'pending';
      } else if (_selectedFilter == 'Confirmed') {
        return status == 'confirmed';
      } else if (_selectedFilter == 'Cancellation Requested') {
        return status == 'cancellation_requested';
      } else if (_selectedFilter == 'Cancelled') {
        return status == 'cancelled';
      } else if (_selectedFilter == 'Completed') {
        return status == 'completed';
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Booking Requests'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.background,
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceVariant,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12.5,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderSubtle,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  );
                },
              ),
            ),
          ),

          // Bookings List
          Expanded(
            child: booking.isLoadingHistory && booking.userBookings.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.car_rental_outlined,
                              size: 60,
                              color: AppColors.textMuted.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No booking requests found',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Your submitted hill station trips will appear here.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            booking.fetchUserBookings(auth.currentUserId),
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            return BookingHistoryCard(
                              booking: item,
                              onCancel: () => _handleCancellation(context, item),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _handleCancellation(BuildContext context, BookingModel item) {
    final isPending = item.bookingStatus.toLowerCase() == 'pending';

    if (isPending) {
      // Pending bookings can be cancelled immediately
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Cancel Booking Request?'),
          content: const Text(
            'Are you sure you want to cancel this booking request? The coordinator will stop driver assignment.',
            style: TextStyle(fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Keep Booking'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                try {
                  await context.read<BookingProvider>().requestCancellation(
                        bookingId: item.bookingId,
                        currentStatus: item.bookingStatus,
                        reason: 'Cancelled by customer before confirmation',
                      );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking request cancelled.'),
                      backgroundColor: AppColors.textSecondary,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to cancel: $e'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
      );
    } else {
      // Confirmed bookings require reason submission for coordinator review
      final reasonController = TextEditingController();
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Request Cancellation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This trip has already been confirmed with a driver. A coordinator will review your cancellation request.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Reason for Cancellation',
                  hintText: 'e.g. Change of travel plans, emergency...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Go Back'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reason = reasonController.text.trim().isEmpty
                    ? 'Customer requested cancellation'
                    : reasonController.text.trim();
                Navigator.pop(dialogCtx);

                try {
                  await context.read<BookingProvider>().requestCancellation(
                        bookingId: item.bookingId,
                        currentStatus: item.bookingStatus,
                        reason: reason,
                      );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Cancellation requested. Coordinator notified.',
                      ),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Request'),
            ),
          ],
        ),
      );
    }
  }
}
