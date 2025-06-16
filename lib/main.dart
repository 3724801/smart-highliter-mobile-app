import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/Splash/splash_screen.dart';
import 'Screens/Navigationbar/main_screen.dart';
import 'Screens/memorize_screen.dart';
import 'Screens/Onboarding/onboarding_screen.dart';
import 'Screens/Profile/user_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    FirebaseOptions firebaseOptions = const FirebaseOptions(
      apiKey: "AIzaSyDCy5UbtFzEIzoaxlgoCwJWKVRxskWp8y4",
      authDomain: "smart-highlighter-b1d3b.firebaseapp.com",
      projectId: "smart-highlighter-b1d3b",
      storageBucket: "smart-highlighter-b1d3b.firebasestorage.app",
      messagingSenderId: "493287639000",
      appId: "1:493287639000:web:53694b1c5548256bb614ad",
      measurementId: "G-TYREKN3X94",
    );

    await Firebase.initializeApp(options: firebaseOptions);
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Highlighter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) =>
            const MainScreen(), // MainScreen فيها BottomNavigationBar
        '/memorize': (context) => const MemorizeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/profile': (context) => const UserProfileScreen(),
      },
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData) {
          // لو المستخدم مسجل دخول، انتقلي تلقائيًا إلى /home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
          return const SizedBox.shrink();
        } else {
          // لو المستخدم مش مسجل دخول
          return const OnboardingScreen();
        }
      },
    );
  }
}
