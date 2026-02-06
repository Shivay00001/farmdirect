import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth_provider.dart';
import '../farmer/farmer_dashboard.dart';
import '../retailer/retailer_home.dart';
import '../delivery/delivery_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  String? _otpId;

  Future<void> _sendOTP() async {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final mobile = _mobileController.text;
    if (mobile.length < 10) return;

    final result = await provider.loginStart(mobile);
    if (result != null) {
      setState(() {
        _otpSent = true;
        _otpId = result['otpId'];
        // Demo helper: Pre-fill OTP
        _otpController.text = result['otp'] ?? ''; 
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP Sent: ${result['otp']}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send OTP. User may not exist.')));
    }
  }

  Future<void> _verifyOTP() async {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.login(_mobileController.text, _otpId!, _otpController.text);

    if (success && mounted) {
       final role = provider.user?.role;
       if (role == 'FARMER') {
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FarmerDashboard()));
       } else if (role == 'RETAILER') {
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RetailerHome()));
       } else if (role == 'DELIVERY') {
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DeliveryDashboard()));
       }
    } else {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _mobileController,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
              enabled: !_otpSent,
            ),
            if (_otpSent) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'OTP'),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 20),
            if (!_otpSent)
              ElevatedButton(onPressed: _sendOTP, child: const Text('Send OTP'))
            else
              ElevatedButton(onPressed: _verifyOTP, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
