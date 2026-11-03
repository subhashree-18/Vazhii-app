class DriverModel {
  final String driverId;
  final String name;
  final String phone;
  final String licenseNumber;
  final String baseCity; // e.g., 'Chennai', 'Coimbatore', 'Madurai', 'Ooty'
  final String assignedVehicleId;
  final bool isActive;
  final double rating;
  final int totalTrips;

  const DriverModel({
    required this.driverId,
    required this.name,
    required this.phone,
    required this.licenseNumber,
    required this.baseCity,
    this.assignedVehicleId = '',
    this.isActive = true,
    this.rating = 4.9,
    this.totalTrips = 45,
  });

  DriverModel copyWith({
    String? driverId,
    String? name,
    String? phone,
    String? licenseNumber,
    String? baseCity,
    String? assignedVehicleId,
    bool? isActive,
    double? rating,
    int? totalTrips,
  }) {
    return DriverModel(
      driverId: driverId ?? this.driverId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      baseCity: baseCity ?? this.baseCity,
      assignedVehicleId: assignedVehicleId ?? this.assignedVehicleId,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'name': name,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'baseCity': baseCity,
      'assignedVehicleId': assignedVehicleId,
      'isActive': isActive,
      'rating': rating,
      'totalTrips': totalTrips,
    };
  }

  factory DriverModel.fromMap(Map<String, dynamic> map, String id) {
    return DriverModel(
      driverId: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      baseCity: map['baseCity'] ?? 'Chennai',
      assignedVehicleId: map['assignedVehicleId'] ?? '',
      isActive: map['isActive'] ?? true,
      rating: (map['rating'] ?? 4.9).toDouble(),
      totalTrips: (map['totalTrips'] ?? 0) as int,
    );
  }
}

/// Sample network drivers in Tamil Nadu
const List<DriverModel> sampleDrivers = [
  DriverModel(
    driverId: 'drv-01',
    name: 'Senthil Kumar',
    phone: '98421 55678',
    licenseNumber: 'TN-43-2015-00431',
    baseCity: 'Ooty / Coimbatore',
    assignedVehicleId: 'veh-innova-01',
    isActive: true,
    rating: 4.95,
    totalTrips: 120,
  ),
  DriverModel(
    driverId: 'drv-02',
    name: 'Muthuvel Pandian',
    phone: '94432 99812',
    licenseNumber: 'TN-57-2017-00982',
    baseCity: 'Madurai / Kodaikanal',
    assignedVehicleId: 'veh-ertiga-02',
    isActive: true,
    rating: 4.88,
    totalTrips: 94,
  ),
  DriverModel(
    driverId: 'drv-03',
    name: 'K. Rajesh',
    phone: '97890 12345',
    licenseNumber: 'TN-01-2019-00124',
    baseCity: 'Chennai',
    assignedVehicleId: 'veh-dzire-03',
    isActive: true,
    rating: 4.92,
    totalTrips: 78,
  ),
  DriverModel(
    driverId: 'drv-04',
    name: 'V. Anandhan',
    phone: '94888 77665',
    licenseNumber: 'TN-30-2016-00778',
    baseCity: 'Salem / Yercaud',
    assignedVehicleId: 'veh-etios-04',
    isActive: true,
    rating: 4.85,
    totalTrips: 62,
  ),
];

