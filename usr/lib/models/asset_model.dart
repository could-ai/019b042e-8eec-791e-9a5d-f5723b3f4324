class AssetModel {
  final String symbol;
  final String name;
  final AssetType type;
  final double currentPrice;
  final bool isBlacklisted;

  AssetModel({
    required this.symbol,
    required this.name,
    required this.type,
    required this.currentPrice,
    this.isBlacklisted = false,
  });

  double getValue(double quantity) => quantity * currentPrice;

  AssetModel copyWith({
    String? symbol,
    String? name,
    AssetType? type,
    double? currentPrice,
    bool? isBlacklisted,
  }) {
    return AssetModel(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      type: type ?? this.type,
      currentPrice: currentPrice ?? this.currentPrice,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
    );
  }
}