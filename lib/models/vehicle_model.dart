class VehicleModel {
  final String vehicleId;
  final String vehicleType; // e.g. '4-Seater Sedan', '7-Seater SUV'
  final String modelName; // e.g. 'Swift Dzire / Toyota Etios / Amaze'
  final int passengerCapacity;
  final String luggageCapacity;
  final int basePrice; // Base price per day (in INR)
  final String acType;
  final String imageUrl;
  final String description;
  final List<String> features;
  final bool isPopular;
  final bool isActive;

  const VehicleModel({
    required this.vehicleId,
    required this.vehicleType,
    required this.modelName,
    required this.passengerCapacity,
    required this.luggageCapacity,
    required this.basePrice,
    required this.acType,
    required this.imageUrl,
    required this.description,
    required this.features,
    this.isPopular = false,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'vehicleType': vehicleType,
      'modelName': modelName,
      'passengerCapacity': passengerCapacity,
      'luggageCapacity': luggageCapacity,
      'basePrice': basePrice,
      'acType': acType,
      'imageUrl': imageUrl,
      'description': description,
      'features': features,
      'isPopular': isPopular,
      'isActive': isActive,
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map, String id) {
    return VehicleModel(
      vehicleId: id,
      vehicleType: map['vehicleType'] ?? '',
      modelName: map['modelName'] ?? '',
      passengerCapacity: (map['passengerCapacity'] ?? 4) as int,
      luggageCapacity: map['luggageCapacity'] ?? '',
      basePrice: (map['basePrice'] ?? 0) as int,
      acType: map['acType'] ?? 'AC Available',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      isPopular: map['isPopular'] ?? false,
      isActive: map['isActive'] ?? true,
    );
  }
}

/// Sample vehicles matching Tamil Nadu hill taxi fleet
const List<VehicleModel> sampleVehicles = [
  VehicleModel(
    vehicleId: 'sedan-prime-4s',
    vehicleType: '4-Seater Sedan',
    modelName: 'Maruti Swift Dzire / Toyota Etios',
    passengerCapacity: 4,
    luggageCapacity: '2 Medium Bags + 2 Handbags',
    basePrice: 3800,
    acType: 'Air Conditioned',
    imageUrl:
        'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=800&q=80',
    description:
        'Ideal for couples and small families. Excellent mileage and comfort on winding hill roads and hairpin bends.',
    features: [
      'Experienced Hill Driver',
      'Spacious Boot Space',
      'Comfortable Rear Seating',
      'Clean & Sanitized Cabin',
    ],
    isPopular: true,
    isActive: true,
  ),
  VehicleModel(
    vehicleId: 'hatchback-compact-4s',
    vehicleType: '4-Seater Hatchback',
    modelName: 'Maruti WagonR / Hyundai i10',
    passengerCapacity: 4,
    luggageCapacity: '1 Large Bag + 2 Handbags',
    basePrice: 3200,
    acType: 'Air Conditioned',
    imageUrl:
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=800&q=80',
    description:
        'Economical choice for quick weekend getaways or day trips. Easy maneuvering in narrow hill town streets.',
    features: [
      'Budget-Friendly Rate',
      'Compact & Agile',
      'Driver Allowance Included',
      'Best for 2-3 Passengers',
    ],
    isPopular: false,
    isActive: true,
  ),
  VehicleModel(
    vehicleId: 'suv-ertiga-7s',
    vehicleType: '7-Seater MUV',
    modelName: 'Maruti Ertiga / Renault Triber',
    passengerCapacity: 6,
    luggageCapacity: '3 Medium Bags + Soft Luggage',
    basePrice: 4800,
    acType: 'Dual AC (Front & Rear)',
    imageUrl:
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=800&q=80',
    description:
        'Perfect for larger families and group travel. Foldable 3rd-row seats provide flexible luggage and seating arrangements.',
    features: [
      'Rear AC Vents',
      'Flexible 3rd Row',
      'Comfortable Long-Distance Ride',
      'Experienced Ghat Driver',
    ],
    isPopular: true,
    isActive: true,
  ),
  VehicleModel(
    vehicleId: 'suv-innova-7s',
    vehicleType: '7-Seater Premium SUV',
    modelName: 'Toyota Innova Crysta',
    passengerCapacity: 7,
    luggageCapacity: '4 Large Bags + Rooftop Carrier',
    basePrice: 6200,
    acType: 'Climate Control / Dual AC',
    imageUrl:
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80',
    description:
        'The gold standard for hill touring in India. Unmatched ride comfort, captain seats, high safety, and robust suspension on rough roads.',
    features: [
      'Captain Seats Option',
      'Rooftop Luggage Carrier',
      'Premium Suspension for Ghats',
      'Highest Safety Rating',
    ],
    isPopular: true,
    isActive: true,
  ),
];

