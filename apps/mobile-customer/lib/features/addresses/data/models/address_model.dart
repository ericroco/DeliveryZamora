import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  AddressModel({
    required super.id,
    required super.name,
    required super.fullAddress,
    required super.details,
    required super.latitude,
    required super.longitude,
    required super.isFavorite,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      name: json['name'] as String,
      fullAddress: json['fullAddress'] as String,
      details: json['details'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullAddress': fullAddress,
      'details': details,
      'latitude': latitude,
      'longitude': longitude,
      'isFavorite': isFavorite,
    };
  }

  factory AddressModel.fromEntity(AddressEntity entity) {
    return AddressModel(
      id: entity.id,
      name: entity.name,
      fullAddress: entity.fullAddress,
      details: entity.details,
      latitude: entity.latitude,
      longitude: entity.longitude,
      isFavorite: entity.isFavorite,
    );
  }
}
