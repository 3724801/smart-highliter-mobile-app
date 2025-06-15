import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/memorize_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
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
    
    // Set persistence to LOCAL to maintain session
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
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
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/welcome': (context) => const WelcomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/home': (context) => const HomeScreen(),
        '/memorize': (context) => const MemorizeScreen(),
      },
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
          // User is logged in
          return const HomeScreen();
        } else {
          // User is not logged in
          return const WelcomeScreen();
        }
      },
    );
  }
}