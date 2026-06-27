import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/address_model.dart';
import 'package:uuid/uuid.dart';

abstract class AddressesRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> saveAddress(AddressModel address);
  Future<void> deleteAddress(String id);
  Future<void> markAsFavorite(String id);
}

class AddressesRemoteDataSourceImpl implements AddressesRemoteDataSource {
  final Dio dio;
  
  // Fake in-memory DB for mockup
  final List<AddressModel> _mockAddresses = [
    AddressModel(
      id: '1',
      name: 'Casa',
      fullAddress: 'Calle Principal 123, Zamora',
      details: 'Piso 2, Puerta A',
      latitude: 41.5033,
      longitude: -5.7463,
      isFavorite: true,
    ),
    AddressModel(
      id: '2',
      name: 'Trabajo',
      fullAddress: 'Avenida de la Feria 45, Zamora',
      details: 'Edificio B',
      latitude: 41.5061,
      longitude: -5.7480,
      isFavorite: false,
    ),
  ];

  AddressesRemoteDataSourceImpl(this.dio);

  @override
  Future<List<AddressModel>> getAddresses() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_mockAddresses);
  }

  @override
  Future<AddressModel> saveAddress(AddressModel address) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (address.id.isEmpty) {
      // Create
      final newAddress = AddressModel(
        id: const Uuid().v4(),
        name: address.name,
        fullAddress: address.fullAddress,
        details: address.details,
        latitude: address.latitude,
        longitude: address.longitude,
        isFavorite: address.isFavorite,
      );
      _mockAddresses.add(newAddress);
      return newAddress;
    } else {
      // Update
      final index = _mockAddresses.indexWhere((a) => a.id == address.id);
      if (index >= 0) {
        _mockAddresses[index] = address;
        return address;
      }
      throw Exception('Dirección no encontrada');
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockAddresses.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> markAsFavorite(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (int i = 0; i < _mockAddresses.length; i++) {
      if (_mockAddresses[i].id == id) {
        _mockAddresses[i] = AddressModel(
          id: _mockAddresses[i].id,
          name: _mockAddresses[i].name,
          fullAddress: _mockAddresses[i].fullAddress,
          details: _mockAddresses[i].details,
          latitude: _mockAddresses[i].latitude,
          longitude: _mockAddresses[i].longitude,
          isFavorite: true,
        );
      } else {
        _mockAddresses[i] = AddressModel(
          id: _mockAddresses[i].id,
          name: _mockAddresses[i].name,
          fullAddress: _mockAddresses[i].fullAddress,
          details: _mockAddresses[i].details,
          latitude: _mockAddresses[i].latitude,
          longitude: _mockAddresses[i].longitude,
          isFavorite: false,
        );
      }
    }
  }
}
