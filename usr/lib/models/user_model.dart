class UserModel {
  final String id;
  final String email;
  final String password; // In production, this would be hashed
  double balance;
  final List<AssetModel> portfolio;
  final List<OrderModel> orderHistory;
  final bool isAdmin;
  final bool isBlacklisted;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.balance,
    required this.portfolio,
    required this.orderHistory,
    this.isAdmin = false,
    this.isBlacklisted = false,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? password,
    double? balance,
    List<AssetModel>? portfolio,
    List<OrderModel>? orderHistory,
    bool? isAdmin,
    bool? isBlacklisted,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      balance: balance ?? this.balance,
      portfolio: portfolio ?? this.portfolio,
      orderHistory: orderHistory ?? this.orderHistory,
      isAdmin: isAdmin ?? this.isAdmin,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
    );
  }
}