import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_data_service.dart';
import '../models/order_model.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  AssetType _assetType = AssetType.stock;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MockDataService>(context);
    final user = service.currentUser;
    if (user == null) return const Center(child: Text('No user logged in'));

    return Scaffold(
      appBar: AppBar(title: const Text('Sell Assets')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<AssetType>(
              value: _assetType,
              items: AssetType.values.map((type) => DropdownMenuItem(value: type, child: Text(type.name))).toList(),
              onChanged: (value) => setState(() => _assetType = value!),
            ),
            TextField(controller: _symbolController, decoration: const InputDecoration(labelText: 'Symbol')),
            TextField(controller: _quantityController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price per Unit'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Text('Available Assets:'),
            Expanded(
              child: ListView.builder(
                itemCount: user.portfolio.length,
                itemBuilder: (context, index) {
                  final asset = user.portfolio[index];
                  return ListTile(title: Text('${asset.symbol} - Qty: 1'), subtitle: Text('Value: $
{asset.getValue(1).toStringAsFixed(2)}')); // Simplified
                },
              ),
            ),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _placeOrder, child: const Text('Place Sell Order')),
          ],
        ),
      ),
    );
  }

  void _placeOrder() async {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    if (quantity <= 0 || price <= 0 || _symbolController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid inputs')));
      return;
    }
    setState(() => _isLoading = true);
    final service = Provider.of<MockDataService>(context, listen: false);
    final success = await service.placeOrder(OrderType.sell, _symbolController.text, quantity, price, _assetType);
    setState(() => _isLoading = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sell order placed')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to place order - check availability or symbol')));
    }
  }
}