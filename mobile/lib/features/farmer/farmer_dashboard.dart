import 'package:flutter/material.dart';
import '../../base_dashboard.dart';
import '../../core/api_client.dart';
import 'add_product_screen.dart';
import 'farmer_orders_screen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyProducts();
  }

  Future<void> _fetchMyProducts() async {
    try {
      final res = await ApiClient().get('/products/my-products');
      if (mounted) {
        setState(() {
          products = res is List ? res : [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
     return BaseDashboard(
       title: 'Farmer Dashboard', 
       role: 'FARMER',
       actions: [
         IconButton(
           icon: const Icon(Icons.list_alt),
           onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerOrdersScreen())),
         )
       ],
       fab: FloatingActionButton(
         child: const Icon(Icons.add),
         onPressed: () async {
           final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
           if (result == true) _fetchMyProducts();
         },
       ),
       body: isLoading 
         ? const Center(child: CircularProgressIndicator()) 
         : products.isEmpty 
           ? const Center(child: Text('No products listed yet.'))
           : ListView.builder(
               itemCount: products.length,
               itemBuilder: (ctx, i) {
                 final p = products[i];
                 return ListTile(
                   title: Text(p['name']),
                   subtitle: Text('Qty: ${p['quantity']} ${p['unit']}'),
                   trailing: Text('₹${p['price_per_unit']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                 );
               },
             ),
     );
  }
}
