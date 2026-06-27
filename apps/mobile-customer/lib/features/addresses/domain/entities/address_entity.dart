class AddressEntity {
  final String id;
  final String name; // e.g., Casa, Trabajo
  final String fullAddress;
  final String details; // Piso, Puerta, etc
  final double latitude;
  final double longitude;
  final bool isFavorite;

  AddressEntity({
    required this.id,
    required this.name,
    required this.fullAddress,
    required this.details,
    required this.latitude,
    required this.longitude,
    required this.isFavorite,
  });

  AddressEntity copyWith({
    String? id,
    String? name,
    String? fullAddress,
    String? details,
    double? latitude,
    double? longitude,
    bool? isFavorite,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      fullAddress: fullAddress ?? this.fullAddress,
      details: details ?? this.details,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
