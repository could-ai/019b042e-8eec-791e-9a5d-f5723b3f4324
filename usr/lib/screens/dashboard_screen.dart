import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_data_service.dart';
import '../models/order_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MockDataService>(context);
    final user = service.currentUser;
    if (user == null) return const Center(child: Text('No user logged in'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(onPressed: service.logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Balance: $
{user.balance.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            const Text('Portfolio:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: user.portfolio.length,
                itemBuilder: (context, index) {
                  final asset = user.portfolio[index];
                  return ListTile(
                    title: Text('${asset.symbol} - ${asset.name}'),
                    subtitle: Text('Value: $
{asset.getValue(1).toStringAsFixed(2)}'), // Assuming quantity 1 for simplicity
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Transaction History:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: user.orderHistory.length,
                itemBuilder: (context, index) {
                  final order = user.orderHistory[index];
                  return ListTile(
                    title: Text('${order.type.name.toUpperCase()} ${order.symbol}'),
                    subtitle: Text('Status: ${order.status.name} | Value: $
{order.totalValue.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/buy'), child: const Text('Buy')),
                ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/sell'), child: const Text('Sell')),
                ElevatedButton(onPressed: () => _showAddFundsDialog(context), child: const Text('Add Funds')),
                ElevatedButton(onPressed: () => _showWithdrawDialog(context), child: const Text('Withdraw')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFundsDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Funds'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              Provider.of<MockDataService>(context, listen: false).addFunds(amount);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Funds'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              Provider.of<MockDataService>(context, listen: false).withdrawFunds(amount);
              Navigator.pop(context);
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}