enum OrderStatus {
  pending,
  confirmed,
  preparing,
  onTheWay,
  delivered,
  cancelled,
}

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
        OrderStatus.pending => 'Pendiente',
        OrderStatus.confirmed => 'Confirmado',
        OrderStatus.preparing => 'Preparando',
        OrderStatus.onTheWay => 'En camino',
        OrderStatus.delivered => 'Entregado',
        OrderStatus.cancelled => 'Cancelado',
      };
}

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
  });

  final String id;
  final String storeName;
  final String storeCategory;
  final double total;
  final int itemCount;
  final OrderStatus status;
  final DateTime createdAt;
  final int? estimatedMinutes;
}
