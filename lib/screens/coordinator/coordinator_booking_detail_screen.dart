import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../models/driver_model.dart';
import '../../services/coordinator_service.dart';

class CoordinatorBookingDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const CoordinatorBookingDetailScreen({super.key, required this.booking});

  @override
  State<CoordinatorBookingDetailScreen> createState() =>
      _CoordinatorBookingDetailScreenState();
}

class _CoordinatorBookingDetailScreenState
    extends State<CoordinatorBookingDetailScreen> {
  late BookingModel _booking;
  List<DriverModel> _drivers = [];
  DriverModel? _selectedDriver;
  final _regController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _regController.text = _booking.vehicleRegistration ?? 'TN-43-E-8899';
    _notesController.text = _booking.coordinatorNotes;
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    final list = await CoordinatorService.instance.getDrivers();
    setState(() {
      _drivers = list;
      if (_drivers.isNotEmpty) {
        _selectedDriver = _drivers.firstWhere(
          (d) => d.name == _booking.driverName,
          orElse: () => _drivers.first,
        );
      }
    });
  }

  @override
  void dispose() {
    _regController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    if (_selectedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an available driver')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await CoordinatorService.instance.confirmBooking(
        bookingId: _booking.bookingId,
        driverName: _selectedDriver!.name,
        vehicleRegistration: _regController.text.trim().isNotEmpty
            ? _regController.text.trim()
            : 'TN-43-E-8899',
        coordinatorNotes: _notesController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking ${_booking.bookingId} Confirmed with ${_selectedDriver!.name}!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.primary),
      );
    }
  }

  Future<void> _declineBooking() async {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Booking Request'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for Declining',
            hintText: 'e.g., No available 7-seater vehicles for date',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              await CoordinatorService.instance.declineBooking(
                bookingId: _booking.bookingId,
                reason: reasonController.text.trim().isNotEmpty
                    ? reasonController.text.trim()
                    : 'Driver unavailable on selected dates',
              );
              if (!mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Decline', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _approveCancellation() async {
    setState(() => _isLoading = true);
    await CoordinatorService.instance.approveCancellation(_booking.bookingId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cancellation approved and booking marked cancelled.')),
    );
    Navigator.pop(context);
  }

  Future<void> _completeTrip() async {
    setState(() => _isLoading = true);
    await CoordinatorService.instance.completeBooking(_booking.bookingId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip marked as Completed!'),
        backgroundColor: AppColors.info,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final status = _booking.bookingStatus.toLowerCase();
    final isPending = status == 'pending';
    final isConfirmed = status == 'confirmed';
    final isCancellationRequested = status == 'cancellation_requested';

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking ${_booking.bookingId}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _booking.destinationName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Chip(
                              label: Text(
                                _booking.bookingStatus.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: isConfirmed
                                  ? AppColors.success
                                  : isPending
                                      ? AppColors.warning
                                      : isCancellationRequested
                                          ? Colors.deepOrange
                                          : AppColors.textSecondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Traveler: ${_booking.customerName} (${_booking.customerPhone})',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pickup: ${_booking.pickupLocation} • ${DateFormat('dd MMM yyyy').format(_booking.travelDate)} (${_booking.durationDays} Days)',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Requested Vehicle: ${_booking.vehicleType} • ${_booking.passengerCount} Passengers',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        if (_booking.specialRequests.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Special Requests: "${_booking.specialRequests}"',
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          'Estimated Package Total: ₹${_booking.estimatedPrice}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Cancellation Request Review Banner (if applicable)
                if (isCancellationRequested) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                            SizedBox(width: 8),
                            Text(
                              'Traveler Requested Cancellation',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Reason: ${_booking.cancellationReason ?? "Customer requested cancellation"}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _approveCancellation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Approve & Cancel Booking'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Driver & Vehicle Assignment Form
                const Text(
                  'Driver & Vehicle Allocation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        DropdownButtonFormField<DriverModel>(
                          initialValue: _selectedDriver,
                          decoration: const InputDecoration(
                            labelText: 'Assign Driver from Network',
                            prefixIcon: Icon(Icons.person_pin_rounded),
                          ),
                          items: _drivers.map((driver) {
                            return DropdownMenuItem<DriverModel>(
                              value: driver,
                              child: Text(
                                '${driver.name} (${driver.phone}) - ${driver.baseCity}',
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedDriver = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _regController,
                          decoration: const InputDecoration(
                            labelText: 'Taxi Registration Number',
                            hintText: 'e.g. TN-43-E-8899',
                            prefixIcon: Icon(Icons.directions_car_rounded),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Coordinator Notes to Traveler',
                            hintText: 'e.g., Driver confirmed. AC Innova arranged.',
                            prefixIcon: Icon(Icons.notes_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Action Buttons
                Row(
                  children: [
                    if (isPending || isCancellationRequested) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _declineBooking,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Decline Request'),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    if (isConfirmed) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _completeTrip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.info,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Mark Trip Completed'),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isConfirmed
                                    ? 'Update Driver Assignment'
                                    : 'Confirm & Assign Driver',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

