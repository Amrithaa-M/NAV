import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/colors.dart';
import '../home/home_screen.dart';
import '../auth/login_screen.dart';

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

  void _checkAuth() async {
    // Wait a brief moment for splash effect and auth state to settle
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.navigation_rounded,
              size: 100,
              color: AppColors.background,
            ),
            const SizedBox(height: 20),
            Text(
              'NAV',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.background,
                fontWeight: FontWeight.bold,
                letterSpacing: 8.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Campus Navigation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.highlightLight,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.highlightLight),
            ),
          ],
        ),
      ),
    );
  }
}
