import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
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

  Future<void> _updateStatus(String orderId, String status) async {
    try {
      await ApiClient().put('/orders/$orderId/status', {'status': status});
      _fetchOrders();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order marked as $status')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Orders')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders received yet.'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) {
                    final order = orders[i];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('Order #${order['id'].toString().substring(0, 8)}'),
                            subtitle: Text('Status: ${order['status']}\nTotal: ₹${order['total_amount']}'),
                            trailing: Text(order['created_at'].toString().split('T')[0]),
                          ),
                          if (order['status'] == 'PENDING')
                            ButtonBar(
                              children: [
                                TextButton(
                                  onPressed: () => _updateStatus(order['id'], 'CANCELLED'),
                                  child: const Text('Reject', style: TextStyle(color: Colors.red)),
                                ),
                                ElevatedButton(
                                  onPressed: () => _updateStatus(order['id'], 'CONFIRMED'),
                                  child: const Text('Accept'),
                                ),
                              ],
                            ),
                          if (order['status'] == 'CONFIRMED')
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_box),
                                onPressed: () => _updateStatus(order['id'], 'READY_FOR_PICKUP'),
                                label: const Text('Mark Ready for Pickup'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
