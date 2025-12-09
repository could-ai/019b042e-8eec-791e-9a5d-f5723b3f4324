enum OrderType { buy, sell }
enum OrderStatus { pending, matched, completed, cancelled }
enum AssetType { stock, crypto }

class OrderModel {
  final String id;
  final String userId;
  final OrderType type;
  final String symbol;
  final double quantity;
  final double price;
  final AssetType assetType;
  OrderStatus status;
  final DateTime createdAt;
  double commission; // Calculated as percentage of total value

  OrderModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.symbol,
    required this.quantity,
    required this.price,
    required this.assetType,
    required this.status,
    required this.createdAt,
    required this.commission,
  });

  double get totalValue => quantity * price;
  double get commissionAmount => totalValue * (commission / 100);

  OrderModel copyWith({
    String? id,
    String? userId,
    OrderType? type,
    String? symbol,
    double? quantity,
    double? price,
    AssetType? assetType,
    OrderStatus? status,
    DateTime? createdAt,
    double? commission,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      assetType: assetType ?? this.assetType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      commission: commission ?? this.commission,
    );
  }
}