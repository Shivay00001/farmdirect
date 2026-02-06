import 'package:flutter/material.dart';
import '../../base_dashboard.dart';
import '../../core/api_client.dart';

class DeliveryDashboard extends StatefulWidget {
  const DeliveryDashboard({super.key});

  @override
  State<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends State<DeliveryDashboard> {
  List<dynamic> availableOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final available = await ApiClient().get('/orders/delivery/available');
      if (mounted) {
        setState(() {
          availableOrders = available is List ? available : [];
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
    return BaseDashboard(
      title: 'Delivery Dashboard', 
      role: 'DELIVERY',
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Available for Pickup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...availableOrders.where((o) => o['status'] == 'READY_FOR_PICKUP').map((order) => Card(
                    child: ListTile(
                        title: Text('Order #${order['id'].substring(0,8)}'),
                        subtitle: Text('Status: ${order['status']}\nTo: Retailer'),
                        trailing: ElevatedButton(
                            onPressed: () => _updateStatus(order['id'], 'OUT_FOR_DELIVERY'),
                            child: const Text('Pick Up')
                        )
                    )
                )),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('My Active Deliveries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...availableOrders.where((o) => o['status'] == 'OUT_FOR_DELIVERY').map((order) => Card(
                    color: Colors.green[50],
                    child: ListTile(
                        title: Text('Order #${order['id'].substring(0,8)}'),
                        subtitle: Text('Delivering to Retailer'),
                        trailing: ElevatedButton(
                            onPressed: () => _updateStatus(order['id'], 'DELIVERED'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            child: const Text('Complete')
                        )
                    )
                )),
            ],
        ),
    );
  }
}
