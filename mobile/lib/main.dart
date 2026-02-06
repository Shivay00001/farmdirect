import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/farmer/farmer_dashboard.dart';
import 'features/retailer/retailer_home.dart';
import 'features/delivery/delivery_dashboard.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const FarmDirectApp(),
    ),
  );
}

class FarmDirectApp extends StatelessWidget {
  const FarmDirectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmDirect',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.tryAutoLogin();
    
    if (!mounted) return;

    if (success) {
      final role = authProvider.user?.role;
      if (role == 'FARMER') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FarmerDashboard()));
      } else if (role == 'RETAILER') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RetailerHome()));
      } else if (role == 'DELIVERY') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DeliveryDashboard()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text('FarmDirect', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
