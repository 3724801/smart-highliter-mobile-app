import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/memorize_screen.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:smart_highlighter_mobilefire/constant.dart';

class MongoDatabase {
  static Future<void> connect() async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var collection = db.collection(COLLECTION_NAME);
      print("✅ Connected to existing database and collection.");
    } catch (e) {
      print("❌ Error: $e");
    }
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.connect();
  // Firebase configuration options for both web and mobile
  FirebaseOptions firebaseOptions = const FirebaseOptions(
      apiKey: "AIzaSyDCy5UbtFzEIzoaxlgoCwJWKVRxskWp8y4",
      authDomain: "smart-highlighter-b1d3b.firebaseapp.com",
      projectId: "smart-highlighter-b1d3b",
      storageBucket: "smart-highlighter-b1d3b.firebasestorage.app",
      messagingSenderId: "493287639000",
      appId: "1:493287639000:web:53694b1c5548256bb614ad",
      measurementId: "G-TYREKN3X94"
  );

  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase SignIn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // This removes the debug banner
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/memorize': (context) => const MemorizeScreen(),

      },
    );
  }
}