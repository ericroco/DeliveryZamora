enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,        // READY: store packed, waiting for driver pickup
  onTheWay,
  delivered,
  cancelled,
}

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
        OrderStatus.pending => 'Pendiente',
        OrderStatus.confirmed => 'Confirmado',
        OrderStatus.preparing => 'Preparando',
        OrderStatus.ready => 'Listo',
        OrderStatus.onTheWay => 'En camino',
        OrderStatus.delivered => 'Entregado',
        OrderStatus.cancelled => 'Cancelado',
      };
}

/// Maps the API's snake_case/UPPER_CASE status strings to [OrderStatus].
OrderStatus orderStatusFromApi(String raw) => switch (raw.toUpperCase()) {
      'PENDING' => OrderStatus.pending,
      'CONFIRMED' => OrderStatus.confirmed,
      'PREPARING' => OrderStatus.preparing,
      'READY' => OrderStatus.ready,
      'PICKED_UP' => OrderStatus.onTheWay,
      'DELIVERED' => OrderStatus.delivered,
      'CANCELLED' => OrderStatus.cancelled,
      _ => OrderStatus.pending,
    };

class Order {
  const Order({
    required this.id,
    required this.storeName,
    required this.storeCategory,
    required this.total,
    required this.itemCount,
    required this.status,
    required this.createdAt,
    this.estimatedMinutes,
    // Tracking fields
    this.driverLat,
    this.driverLng,
    this.driverName,
    this.driverVehicleType,
    this.driverPlate,
    this.deliveryAddress,
    this.storeLat,
    this.storeLng,
  });

  final String id;
  final String storeName;
  final String storeCategory;
  final double total;
  final int itemCount;
  final OrderStatus status;
  final DateTime createdAt;
  final int? estimatedMinutes;

  // Real-time driver location (null until driver picks up)
  final double? driverLat;
  final double? driverLng;

  // Driver info (null until order is assigned to a driver)
  final String? driverName;
  final String? driverVehicleType;
  final String? driverPlate;

  // Delivery address & store coordinates for map
  final String? deliveryAddress;
  final double? storeLat;
  final double? storeLng;

  factory Order.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>?;
    final store = json['store'] as Map<String, dynamic>?;
    final items = json['items'] as List<dynamic>? ?? [];

    return Order(
      id: json['id'] as String,
      storeName: store?['name'] as String? ?? '',
      storeCategory: '',
      total: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
      itemCount: items.length,
      status: orderStatusFromApi(json['status'] as String? ?? 'PENDING'),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      driverLat: (json['driverLat'] as num?)?.toDouble(),
      driverLng: (json['driverLng'] as num?)?.toDouble(),
      driverName: driver?['name'] as String?,
      driverVehicleType: driver?['vehicleType'] as String?,
      driverPlate: driver?['plate'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      storeLat: (store?['latitude'] as num?)?.toDouble(),
      storeLng: (store?['longitude'] as num?)?.toDouble(),
    );
  }
}
