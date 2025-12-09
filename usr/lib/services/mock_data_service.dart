import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/asset_model.dart';

class MockDataService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Mock data - replace with Supabase calls later
  List<UserModel> _users = [
    UserModel(
      id: '1',
      email: 'user@example.com',
      password: 'password',
      balance: 10000.0,
      portfolio: [],
      orderHistory: [],
    ),
    UserModel(
      id: '2',
      email: 'admin@example.com',
      password: 'admin',
      balance: 0.0,
      portfolio: [],
      orderHistory: [],
      isAdmin: true,
    ),
  ];

  List<AssetModel> _assets = [
    AssetModel(symbol: 'AAPL', name: 'Apple Inc.', type: AssetType.stock, currentPrice: 150.0),
    AssetModel(symbol: 'GOOGL', name: 'Alphabet Inc.', type: AssetType.stock, currentPrice: 2800.0),
    AssetModel(symbol: 'BTC', name: 'Bitcoin', type: AssetType.crypto, currentPrice: 50000.0),
    AssetModel(symbol: 'ETH', name: 'Ethereum', type: AssetType.crypto, currentPrice: 3000.0),
  ];

  List<OrderModel> _orders = [];
  double _commissionRate = 2.0; // Base 2%, adjustable
  UserModel? _currentUser;

  MockDataService() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: IOSInitializationSettings(),
    );
    _notificationsPlugin.initialize(initializationSettings);
  }

  // Authentication
  Future<bool> login(String email, String password) async {
    final user = _users.firstWhere(
      (u) => u.email == email && u.password == password,
      orElse: () => UserModel(id: '', email: '', password: '', balance: 0, portfolio: [], orderHistory: []),
    );
    if (user.id.isNotEmpty) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    if (_users.any((u) => u.email == email)) return false;
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      password: password,
      balance: 0.0,
      portfolio: [],
      orderHistory: [],
    );
    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return true;
  }

  // User management
  UserModel? get currentUser => _currentUser;
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Portfolio and balance
  void addFunds(double amount) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(balance: _currentUser!.balance + amount);
      _notify('Funds Added', '$
amount added to your balance');
      notifyListeners();
    }
  }

  void withdrawFunds(double amount) {
    if (_currentUser != null && _currentUser!.balance >= amount) {
      _currentUser = _currentUser!.copyWith(balance: _currentUser!.balance - amount);
      _notify('Funds Withdrawn', '$
amount withdrawn from your account');
      notifyListeners();
    }
  }

  // Orders
  Future<bool> placeOrder(OrderType type, String symbol, double quantity, double price, AssetType assetType) async {
    if (_currentUser == null) return false;

    final asset = _assets.firstWhere((a) => a.symbol == symbol);
    if (asset.isBlacklisted) return false;

    if (type == OrderType.buy && _currentUser!.balance < (quantity * price) * (1 + _commissionRate / 100)) {
      return false; // Insufficient funds
    }

    if (type == OrderType.sell) {
      final portfolioItem = _currentUser!.portfolio.firstWhere(
        (p) => p.symbol == symbol,
        orElse: () => AssetModel(symbol: '', name: '', type: assetType, currentPrice: 0),
      );
      if (portfolioItem.symbol.isEmpty || portfolioItem.getValue(quantity) < quantity * price) {
        return false; // Insufficient assets
      }
    }

    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUser!.id,
      type: type,
      symbol: symbol,
      quantity: quantity,
      price: price,
      assetType: assetType,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      commission: _commissionRate,
    );

    _orders.add(order);
    _currentUser!.orderHistory.add(order);
    _notify('Order Placed', '${type.name.toUpperCase()} order for $symbol submitted');
    _matchOrders();
    notifyListeners();
    return true;
  }

  void _matchOrders() {
    // Simple matching: pair buy/sell if prices match
    final buyOrders = _orders.where((o) => o.type == OrderType.buy && o.status == OrderStatus.pending).toList();
    final sellOrders = _orders.where((o) => o.type == OrderType.sell && o.status == OrderStatus.pending).toList();

    for (final buy in buyOrders) {
      final matchingSell = sellOrders.firstWhere(
        (sell) => sell.symbol == buy.symbol && sell.price <= buy.price,
        orElse: () => OrderModel(id: '', userId: '', type: OrderType.sell, symbol: '', quantity: 0, price: 0, assetType: AssetType.stock, status: OrderStatus.pending, createdAt: DateTime.now(), commission: 0),
      );
      if (matchingSell.id.isNotEmpty) {
        // Execute match
        final matchedQuantity = buy.quantity < matchingSell.quantity ? buy.quantity : matchingSell.quantity;
        final commission = (matchedQuantity * buy.price) * (buy.commission / 100);

        // Update buyers
        final buyer = _users.firstWhere((u) => u.id == buy.userId);
        buyer.balance -= (matchedQuantity * buy.price) + commission;
        final buyerAsset = buyer.portfolio.firstWhere(
          (a) => a.symbol == buy.symbol,
          orElse: () => AssetModel(symbol: buy.symbol, name: buy.symbol, type: buy.assetType, currentPrice: buy.price),
        );
        if (buyerAsset.symbol == buy.symbol) {
          buyer.portfolio[buyer.portfolio.indexOf(buyerAsset)] = buyerAsset.copyWith(
            currentPrice: buy.price, // Update to match price
          );
        } else {
          buyer.portfolio.add(AssetModel(symbol: buy.symbol, name: buy.symbol, type: buy.assetType, currentPrice: buy.price));
        }

        // Update sellers
        final seller = _users.firstWhere((u) => u.id == matchingSell.userId);
        seller.balance += (matchedQuantity * matchingSell.price) - commission;
        seller.portfolio.removeWhere((a) => a.symbol == matchingSell.symbol && a.getValue(matchedQuantity) >= matchedQuantity * matchingSell.price);

        // Update orders
        buy.status = OrderStatus.matched;
        matchingSell.status = OrderStatus.matched;
        _notify('Order Matched', 'Your ${buy.type.name} order for $buy.symbol has been matched');
        _notify('Order Matched', 'Your ${matchingSell.type.name} order for $matchingSell.symbol has been matched');
      }
    }
  }

  // Getters for UI
  List<OrderModel> get pendingOrders => _orders.where((o) => o.status == OrderStatus.pending).toList();
  List<OrderModel> get completedOrders => _orders.where((o) => o.status == OrderStatus.completed || o.status == OrderStatus.matched).toList();
  List<UserModel> get users => _users;
  List<AssetModel> get assets => _assets;
  double get commissionRate => _commissionRate;

  // Admin functions
  void setCommissionRate(double rate) {
    _commissionRate = rate;
    notifyListeners();
  }

  void toggleUserBlacklist(String userId) {
    final user = _users.firstWhere((u) => u.id == userId);
    _users[_users.indexOf(user)] = user.copyWith(isBlacklisted: !user.isBlacklisted);
    notifyListeners();
  }

  void toggleAssetBlacklist(String symbol) {
    final asset = _assets.firstWhere((a) => a.symbol == symbol);
    _assets[_assets.indexOf(asset)] = asset.copyWith(isBlacklisted: !asset.isBlacklisted);
    notifyListeners();
  }

  double getTotalProfits() {
    return _orders.where((o) => o.status == OrderStatus.matched).fold(0.0, (sum, o) => sum + o.commissionAmount);
  }

  // Notifications
  void _notify(String title, String body) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails('channel_id', 'Marketplace Notifications'),
      iOS: IOSNotificationDetails(),
    );
    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }

  // TODO: Replace all mock data with Supabase calls once connected
  // TODO: Add real authentication with Supabase Auth
  // TODO: Implement real-time order matching with Supabase Edge Functions
  // TODO: Add Stripe/PayPal payment integration via Edge Functions
  // TODO: Add real notifications via push services
}