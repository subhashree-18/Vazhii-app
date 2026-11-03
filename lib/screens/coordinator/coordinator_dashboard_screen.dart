import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../services/coordinator_service.dart';
import 'coordinator_booking_detail_screen.dart';
import 'coordinator_drivers_screen.dart';

class CoordinatorDashboardScreen extends StatefulWidget {
  const CoordinatorDashboardScreen({super.key});

  @override
  State<CoordinatorDashboardScreen> createState() =>
      _CoordinatorDashboardScreenState();
}

class _CoordinatorDashboardScreenState
    extends State<CoordinatorDashboardScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = const [
    'All',
    'Pending',
    'Confirmed',
    'Cancellation Requested',
    'Completed',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Coordinator Command Center'),
        actions: [
          IconButton(
            tooltip: 'Driver Fleet Management',
            icon: const Icon(Icons.people_alt_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CoordinatorDriversScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: CoordinatorService.instance.streamAllBookings(),
        builder: (context, snapshot) {
          final allBookings = snapshot.data ?? [];

          final pendingCount = allBookings
              .where((b) => b.bookingStatus.toLowerCase() == 'pending')
              .length;
          final confirmedCount = allBookings
              .where((b) => b.bookingStatus.toLowerCase() == 'confirmed')
              .length;
          final cancellationCount = allBookings
              .where((b) =>
                  b.bookingStatus.toLowerCase() == 'cancellation_requested')
              .length;
          final completedCount = allBookings
              .where((b) => b.bookingStatus.toLowerCase() == 'completed')
              .length;

          final filteredBookings = allBookings.where((b) {
            final s = b.bookingStatus.toLowerCase();
            if (_selectedFilter == 'Pending') return s == 'pending';
            if (_selectedFilter == 'Confirmed') return s == 'confirmed';
            if (_selectedFilter == 'Cancellation Requested') {
              return s == 'cancellation_requested';
            }
            if (_selectedFilter == 'Completed') return s == 'completed';
            return true;
          }).toList();

          return Column(
            children: [
              // Summary Metrics Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    _buildStatCard(
                      label: 'Pending Requests',
                      count: pendingCount,
                      color: AppColors.warning,
                      icon: Icons.hourglass_top_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      label: 'Confirmed Trips',
                      count: confirmedCount,
                      color: AppColors.success,
                      icon: Icons.check_circle_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      label: 'Cancel Requests',
                      count: cancellationCount,
                      color: Colors.deepOrange,
                      icon: Icons.assignment_return_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      label: 'Completed Trips',
                      count: completedCount,
                      color: AppColors.info,
                      icon: Icons.done_all_rounded,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),

              // Filter Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.white,
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
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
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12.5,
                        ),
                        onSelected: (_) {
                          setState(() => _selectedFilter = filter);
                        },
                      );
                    },
                  ),
                ),
              ),

              // Bookings Table/List
              Expanded(
                child: filteredBookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 48,
                              color: AppColors.textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No bookings under this status',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final item = filteredBookings[index];
                          return _buildBookingRowCard(context, item);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingRowCard(BuildContext context, BookingModel item) {
    final status = item.bookingStatus.toLowerCase();
    final isPending = status == 'pending';
    final isConfirmed = status == 'confirmed';
    final isCancellationRequested = status == 'cancellation_requested';

    Color statusColor = AppColors.textSecondary;
    if (isPending) statusColor = AppColors.warning;
    if (isConfirmed) statusColor = AppColors.success;
    if (isCancellationRequested) statusColor = Colors.deepOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CoordinatorBookingDetailScreen(booking: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.bookingId,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.bookingStatus.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.destinationName} • Pickup: ${item.pickupLocation.split('(').first.trim()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Customer: ${item.customerName} (${item.customerPhone}) • ${item.vehicleType}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date: ${DateFormat('dd MMM yyyy').format(item.travelDate)} (${item.durationDays} Days) • ₹${item.estimatedPrice}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CoordinatorBookingDetailScreen(booking: item),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPending
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    foregroundColor: isPending ? Colors.white : AppColors.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isPending ? 'Assign Driver' : 'Manage'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
