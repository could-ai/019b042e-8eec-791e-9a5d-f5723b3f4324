import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_data_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MockDataService>(context);
    final users = service.users;
    final pendingOrders = service.pendingOrders;
    final completedOrders = service.completedOrders;
    final totalProfits = service.getTotalProfits();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Commission Rate: ${service.commissionRate}%'),
            Slider(
              value: service.commissionRate,
              min: 0,
              max: 10,
              onChanged: (value) => service.setCommissionRate(value),
            ),
            const SizedBox(height: 20),
            const Text('Users:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user.email),
                    subtitle: Text('Balance: $
{user.balance.toStringAsFixed(2)} | Blacklisted: ${user.isBlacklisted}'),
                    trailing: IconButton(
                      icon: Icon(user.isBlacklisted ? Icons.check_circle : Icons.block),
                      onPressed: () => service.toggleUserBlacklist(user.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Active Orders:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: pendingOrders.length,
                itemBuilder: (context, index) {
                  final order = pendingOrders[index];
                  return ListTile(
                    title: Text('${order.type.name.toUpperCase()} ${order.symbol}'),
                    subtitle: Text('Qty: ${order.quantity} | Price: $
{order.price}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text('Total Profits: $
{totalProfits.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            const Text('Assets:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: service.assets.length,
                itemBuilder: (context, index) {
                  final asset = service.assets[index];
                  return ListTile(
                    title: Text('${asset.symbol} - ${asset.name}'),
                    subtitle: Text('Blacklisted: ${asset.isBlacklisted}'),
                    trailing: IconButton(
                      icon: Icon(asset.isBlacklisted ? Icons.check_circle : Icons.block),
                      onPressed: () => service.toggleAssetBlacklist(asset.symbol),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}