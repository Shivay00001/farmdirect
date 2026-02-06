import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class RetailerOrdersScreen extends StatefulWidget {
  const RetailerOrdersScreen({super.key});

  @override
  State<RetailerOrdersScreen> createState() => _RetailerOrdersScreenState();
}

class _RetailerOrdersScreenState extends State<RetailerOrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final res = await ApiClient().get('/orders/my-orders');
      if (mounted) {
        setState(() {
          orders = res is List ? res : [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders placed yet.'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) {
                    final order = orders[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.shopping_bag, color: Colors.green),
                        title: Text('Order #${order['id'].substring(0, 8)}'),
                        subtitle: Text('Status: ${order['status']}'),
                        trailing: Text('₹${order['total_amount']}'),
                      ),
                    );
                  },
                ),
    );
  }
}
