import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/auth_provider.dart';
import 'features/auth/login_screen.dart';

class BaseDashboard extends StatelessWidget {
  final String title;
  final String role;
  final Widget? body;
  final FloatingActionButton? fab;

  const BaseDashboard({
    super.key,
    required this.title,
    required this.role,
    this.body,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: body ?? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, $role', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            const Text('Feature coming soon...'),
          ],
        ),
      ),
      floatingActionButton: fab,
    );
  }
}
