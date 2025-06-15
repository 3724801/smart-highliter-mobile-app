import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Navigate after delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/intro');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo without background
              Image.asset(
                'assets/images/logo.png',
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
              
              const SizedBox(height: 40),
              
              // App Name
              const Text(
                'Smart Highlighter',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                  letterSpacing: 1.2,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Intelligent Text Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF37474F),
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Simple Loading Indicator
              const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF00BCD4),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF546E7A),
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Version Info
              const Text(
                'Version 1.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF78909C),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}