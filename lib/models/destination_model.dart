class DestinationModel {
  final String destinationId;
  final String name;
  final String tamilName;
  final String tagline;
  final String description;
  final String imageUrl;
  final String location; // District / Region
  final String elevation;
  final String distanceFromChennai;
  final int startingPricePerDay;
  final List<String> popularSpots;
  final String category;
  final bool isPopular;
  final bool isActive;

  const DestinationModel({
    required this.destinationId,
    required this.name,
    required this.tamilName,
    required this.tagline,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.elevation,
    required this.distanceFromChennai,
    required this.startingPricePerDay,
    required this.popularSpots,
    required this.category,
    this.isPopular = false,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'destinationId': destinationId,
      'name': name,
      'tamilName': tamilName,
      'tagline': tagline,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'elevation': elevation,
      'distanceFromChennai': distanceFromChennai,
      'startingPricePerDay': startingPricePerDay,
      'popularSpots': popularSpots,
      'category': category,
      'isPopular': isPopular,
      'isActive': isActive,
    };
  }

  factory DestinationModel.fromMap(Map<String, dynamic> map, String id) {
    return DestinationModel(
      destinationId: id,
      name: map['name'] ?? '',
      tamilName: map['tamilName'] ?? '',
      tagline: map['tagline'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'] ?? '',
      elevation: map['elevation'] ?? '',
      distanceFromChennai: map['distanceFromChennai'] ?? '',
      startingPricePerDay: (map['startingPricePerDay'] ?? 0) as int,
      popularSpots: List<String>.from(map['popularSpots'] ?? []),
      category: map['category'] ?? 'Hill Station',
      isPopular: map['isPopular'] ?? false,
      isActive: map['isActive'] ?? true,
    );
  }
}

/// Reusable sample data for Tamil Nadu hill stations & getaways.
/// Used for local preview and seeded into Firestore.
const List<DestinationModel> sampleDestinations = [
  DestinationModel(
    destinationId: 'ooty',
    name: 'Ooty (Udhagamandalam)',
    tamilName: 'ஊட்டி',
    tagline: 'Queen of Hill Stations',
    description:
        'Famous for lush tea estates, Doddabetta Peak, botanical gardens, and the heritage Nilgiri Mountain Railway.',
    imageUrl:
        'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?auto=format&fit=crop&w=800&q=80',
    location: 'Nilgiris District',
    elevation: '2,240 m',
    distanceFromChennai: '540 km',
    startingPricePerDay: 4800,
    popularSpots: [
      'Doddabetta Peak',
      'Botanical Garden',
      'Pykara Waterfalls',
      'Ooty Lake',
      'Tea Factory',
    ],
    category: 'Hill Station',
    isPopular: true,
    isActive: true,
  ),
  DestinationModel(
    destinationId: 'kodaikanal',
    name: 'Kodaikanal',
    tamilName: 'கொடைக்கானல்',
    tagline: 'Princess of Hill Stations',
    description:
        'Set around a star-shaped lake, featuring misty cliffs, pine forests, Pillar Rocks, and cool mountain air.',
    imageUrl:
        'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=800&q=80',
    location: 'Dindigul District',
    elevation: '2,133 m',
    distanceFromChennai: '525 km',
    startingPricePerDay: 4600,
    popularSpots: [
      'Kodai Lake',
      'Pillar Rocks',
      'Coaker’s Walk',
      'Silver Cascade',
      'Pine Forest',
    ],
    category: 'Hill Station',
    isPopular: true,
    isActive: true,
  ),
  DestinationModel(
    destinationId: 'yercaud',
    name: 'Yercaud',
    tamilName: 'ஏற்காடு',
    tagline: 'Jewel of the Shevaroys',
    description:
        'A tranquil hill town near Salem famous for coffee plantations, the Emerald Lake, and panoramic viewpoint Pagoda Point.',
    imageUrl:
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
    location: 'Salem District',
    elevation: '1,515 m',
    distanceFromChennai: '365 km',
    startingPricePerDay: 3800,
    popularSpots: [
      'Yercaud Lake',
      'Pagoda Point',
      'Lady’s Seat',
      'Killiyur Falls',
      'Botanical Garden',
    ],
    category: 'Hill Station',
    isPopular: true,
    isActive: true,
  ),
  DestinationModel(
    destinationId: 'valparai',
    name: 'Valparai',
    tamilName: 'வால்பாறை',
    tagline: 'Untouched Anamalai Hills',
    description:
        'Known for 40 thrilling hairpin bends, pristine tea plantations, rare lion-tailed macaques, and Sholayar Dam.',
    imageUrl:
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
    location: 'Coimbatore District',
    elevation: '1,193 m',
    distanceFromChennai: '585 km',
    startingPricePerDay: 5000,
    popularSpots: [
      '40 Hairpin Bends',
      'Aliyar Dam',
      'Sholayar Dam',
      'Loam’s Viewpoint',
      'Monkey Falls',
    ],
    category: 'Wildlife & Hills',
    isPopular: true,
    isActive: true,
  ),
  DestinationModel(
    destinationId: 'kolli-hills',
    name: 'Kolli Hills (Kolli Malai)',
    tamilName: 'கொல்லிமலை',
    tagline: 'Mountain of 70 Hairpin Bends',
    description:
        'Famous for the Agaya Gangai waterfall, ancient Arapaleeswarar temple, medical herbs, and 70 consecutive hairpin curves.',
    imageUrl:
        'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=800&q=80',
    location: 'Namakkal District',
    elevation: '1,300 m',
    distanceFromChennai: '370 km',
    startingPricePerDay: 4200,
    popularSpots: [
      'Agaya Gangai Waterfalls',
      'Arapaleeswarar Temple',
      'Seekuparai Viewpoint',
      '70 Hairpin Bends',
    ],
    category: 'Hill Station',
    isPopular: false,
    isActive: true,
  ),
  DestinationModel(
    destinationId: 'meghamalai',
    name: 'Meghamalai (Highwavys)',
    tamilName: 'மேகமலை',
    tagline: 'High Waves in the Clouds',
    description:
        'A serene mountain sanctuary hidden among cardamon, coffee, and tea estates with scenic mist-clad reservoirs.',
    imageUrl:
        'https://images.unsplash.com/photo-1426604966848-d7adac402bff?auto=format&fit=crop&w=800&q=80',
    location: 'Theni District',
    elevation: '1,500 m',
    distanceFromChennai: '550 km',
    startingPricePerDay: 4900,
    popularSpots: [
      'Highwavys Dam',
      'Cloud Mountain View',
      'Manalar Dam',
      'Venniyar Tea Estate',
    ],
    category: 'Wildlife & Hills',
    isPopular: false,
    isActive: true,
  ),
];

