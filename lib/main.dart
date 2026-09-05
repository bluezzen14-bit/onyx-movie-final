import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

const skyBlue = Color(0xFF38BDF8);
const skyDeep = Color(0xFF0EA5E9);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAqhqupsd2veboIOFZfIjaNNOKpKxlV2MI",
      authDomain: "onyx-movies-2b58b.firebaseapp.com",
      databaseURL: "https://onyx-movies-2b58b-default-rtdb.firebaseio.com",
      projectId: "onyx-movies-2b58b",
      storageBucket: "onyx-movies-2b58b.firebasestorage.app",
      messagingSenderId: "243702982500",
      appId: "1:243702982500:web:a65b9c59dd2e06c3ec7c71",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [skyDeep, Color(0xFF020617)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_circle_fill_rounded, size: 60, color: skyBlue),
                    const SizedBox(height: 12),
                    const Text("ONYX MOVIES", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Text("iOS 26 Liquid Glass - Sky Blue", style: TextStyle(color: skyBlue, fontSize: 10)),
                    const SizedBox(height: 20),
                    SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: skyBlue, foregroundColor: Colors.black), onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())); }, child: const Text("CONTINUE", style: TextStyle(fontWeight: FontWeight.bold)))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(backgroundColor: skyBlue, title: const Text("ONYX v1.0.4 Sky Blue", style: TextStyle(color: Colors.black))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ClipRRect(borderRadius: BorderRadius.circular(16), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), child: Container(height: 48, color: Colors.white.withOpacity(0.1), padding: const EdgeInsets.symmetric(horizontal: 12), child: const Row(children: [Icon(Icons.search_rounded, color: skyBlue, size: 20), SizedBox(width: 8), Text("Search movies, VJ, Genre - Liquid Glass", style: TextStyle(color: Colors.white38, fontSize: 11))])))),
        const SizedBox(height: 16),
        Container(height: 160, decoration: BoxDecoration(color: skyBlue.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CupertinoActivityIndicator(radius: 10, color: Colors.white), SizedBox(height: 8), Text("Banner 7 Latest - iPhone loading small transparent", style: TextStyle(color: Colors.white70, fontSize: 10))]))),
        const SizedBox(height: 16),
        const Text("Latest Release", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(height: 110, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: 5, separatorBuilder: (_,__)=>const SizedBox(width: 10), itemBuilder: (_,i)=>Container(width: 90, decoration: BoxDecoration(color: skyBlue.withOpacity(0.25), borderRadius: BorderRadius.circular(14)), child: Stack(children: [const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white)), Positioned(top: 6, right: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: skyBlue, borderRadius: BorderRadius.circular(6)), child: const Text("VJ Junior", style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Colors.black))))])))),
      ]),
    );
  }
}
