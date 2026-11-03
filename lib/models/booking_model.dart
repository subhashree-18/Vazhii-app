class BookingModel {
  final String bookingId;
  final String userId;
  final String pickupLocation;
  final String destinationId;
  final String destinationName;
  final DateTime travelDate;
  final int durationDays;
  final int passengerCount;
  final String vehicleId;
  final String vehicleType;
  final String vehicleModelName;
  final String customerName;
  final String customerPhone;
  final String specialRequests;
  final int estimatedPrice;
  // Statuses: 'pending', 'confirmed', 'cancellation_requested', 'rejected', 'cancelled', 'completed'
  final String bookingStatus;
  final DateTime createdAt;
  final String coordinatorNotes;
  final String? driverName;
  final String? vehicleRegistration;
  final String? cancellationReason;
  final DateTime? cancellationRequestedAt;

  const BookingModel({
    required this.bookingId,
    required this.userId,
    required this.pickupLocation,
    required this.destinationId,
    required this.destinationName,
    required this.travelDate,
    required this.durationDays,
    required this.passengerCount,
    required this.vehicleId,
    required this.vehicleType,
    required this.vehicleModelName,
    required this.customerName,
    required this.customerPhone,
    this.specialRequests = '',
    required this.estimatedPrice,
    this.bookingStatus = 'pending',
    required this.createdAt,
    this.coordinatorNotes = '',
    this.driverName,
    this.vehicleRegistration,
    this.cancellationReason,
    this.cancellationRequestedAt,
  });

  BookingModel copyWith({
    String? bookingId,
    String? userId,
    String? pickupLocation,
    String? destinationId,
    String? destinationName,
    DateTime? travelDate,
    int? durationDays,
    int? passengerCount,
    String? vehicleId,
    String? vehicleType,
    String? vehicleModelName,
    String? customerName,
    String? customerPhone,
    String? specialRequests,
    int? estimatedPrice,
    String? bookingStatus,
    DateTime? createdAt,
    String? coordinatorNotes,
    String? driverName,
    String? vehicleRegistration,
    String? cancellationReason,
    DateTime? cancellationRequestedAt,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationId: destinationId ?? this.destinationId,
      destinationName: destinationName ?? this.destinationName,
      travelDate: travelDate ?? this.travelDate,
      durationDays: durationDays ?? this.durationDays,
      passengerCount: passengerCount ?? this.passengerCount,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModelName: vehicleModelName ?? this.vehicleModelName,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      specialRequests: specialRequests ?? this.specialRequests,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      createdAt: createdAt ?? this.createdAt,
      coordinatorNotes: coordinatorNotes ?? this.coordinatorNotes,
      driverName: driverName ?? this.driverName,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationRequestedAt:
          cancellationRequestedAt ?? this.cancellationRequestedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'pickupLocation': pickupLocation,
      'destinationId': destinationId,
      'destinationName': destinationName,
      'travelDate': travelDate.toIso8601String(),
      'durationDays': durationDays,
      'passengerCount': passengerCount,
      'vehicleId': vehicleId,
      'vehicleType': vehicleType,
      'vehicleModelName': vehicleModelName,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'specialRequests': specialRequests,
      'estimatedPrice': estimatedPrice,
      'bookingStatus': bookingStatus,
      'createdAt': createdAt.toIso8601String(),
      'coordinatorNotes': coordinatorNotes,
      if (driverName != null) 'driverName': driverName,
      if (vehicleRegistration != null) 'vehicleRegistration': vehicleRegistration,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (cancellationRequestedAt != null)
        'cancellationRequestedAt': cancellationRequestedAt!.toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      bookingId: id,
      userId: map['userId'] ?? '',
      pickupLocation: map['pickupLocation'] ?? '',
      destinationId: map['destinationId'] ?? '',
      destinationName: map['destinationName'] ?? '',
      travelDate: DateTime.tryParse(map['travelDate'] ?? '') ?? DateTime.now(),
      durationDays: (map['durationDays'] ?? 1) as int,
      passengerCount: (map['passengerCount'] ?? 1) as int,
      vehicleId: map['vehicleId'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      vehicleModelName: map['vehicleModelName'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      specialRequests: map['specialRequests'] ?? '',
      estimatedPrice: (map['estimatedPrice'] ?? 0) as int,
      bookingStatus: map['bookingStatus'] ?? 'pending',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      coordinatorNotes: map['coordinatorNotes'] ?? '',
      driverName: map['driverName'],
      vehicleRegistration: map['vehicleRegistration'],
      cancellationReason: map['cancellationReason'],
      cancellationRequestedAt: map['cancellationRequestedAt'] != null
          ? DateTime.tryParse(map['cancellationRequestedAt'])
          : null,
    );
  }
}
