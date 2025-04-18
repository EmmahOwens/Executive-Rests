import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.checkAuthStatus();
    
    if (!mounted) return;
    
    if (authService.isAuthenticated) {
      if (authService.currentUser?.userType == 'tenant') {
        Navigator.of(context).pushReplacementNamed('/tenant-dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/landlord-dashboard');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo container with neumorphic effect
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(5, 5),
                    blurRadius: 15,
                  ),
                  const BoxShadow(
                    color: Color(0xFF2A4BA0),
                    offset: Offset(-5, -5),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "ER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Executive Rests",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Premium Rental Management",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}