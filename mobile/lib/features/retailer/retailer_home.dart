import 'package:flutter/material.dart';
import '../../base_dashboard.dart';
import '../../core/api_client.dart';
import 'retailer_orders_screen.dart';

class RetailerHome extends StatefulWidget {
  const RetailerHome({super.key});

  @override
  State<RetailerHome> createState() => _RetailerHomeState();
}

class _RetailerHomeState extends State<RetailerHome> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final res = await ApiClient().get('/products/search'); // Fetches all active products if no query
      if (mounted) {
        setState(() {
          products = res;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
         setState(() => isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      title: 'Marketplace',
      role: 'RETAILER',
      actions: [
         IconButton(
           icon: const Icon(Icons.history),
           onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RetailerOrdersScreen())),
         )
      ],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchProducts,
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (ctx, i) {
                  final p = products[i];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: p['images'] != null && (p['images'] as List).isNotEmpty
                          ? Image.network(p['images'][0], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image))
                          : const Icon(Icons.agriculture, size: 50),
                      title: Text(p['name']),
                      subtitle: Text('₹${p['price_per_unit']}/${p['unit']} • ${p['farmer_name'] ?? 'Farmer'}'),
                      trailing: ElevatedButton(
                        child: const Text('Buy'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              final qtyController = TextEditingController(text: '1');
                              return AlertDialog(
                                title: Text('Buy ${p['name']}'),
                                content: TextField(
                                  controller: qtyController,
                                  decoration: const InputDecoration(labelText: 'Quantity'),
                                  keyboardType: TextInputType.number,
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      try {
                                        final qty = double.tryParse(qtyController.text) ?? 1;
                                        await ApiClient().post('/orders/create', {
                                          'items': [{'product_id': p['id'], 'quantity': qty}],
                                          'delivery_address': {'line1': 'Default Address'}, // Demo address
                                          'payment_method': 'COD'
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Placed!')));
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                                      }
                                    },
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              );
                            }
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
