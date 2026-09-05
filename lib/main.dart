import 'package:flutter/material.dart';

void main() {
  runApp(const OnyxApp());
}

class OnyxApp extends StatelessWidget {
  const OnyxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Onyx Movies',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text("ONYX", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4)),
          const Spacer(),
          const Icon(Icons.movie_filter_rounded, size: 120, color: Colors.white),
          const SizedBox(height: 20),
          const Text("ONYX MOVIES", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("iOS 26 Liquid Glass Edition", style: TextStyle(color: Colors.white54, fontSize: 16)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  // THIS IS THE FIX - NOW IT WORKS!
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: const Text("ENTER APP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ONYX MOVIES"), backgroundColor: Colors.black, centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(height: 200, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)), child: const Center(child: Text("🎬 Featured Movie", style: TextStyle(fontSize: 24)))),
          const SizedBox(height: 20),
          const Text("Trending Now", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, i) => Container(width: 100, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(15)), child: Center(child: Text("Movie ${i+1}"))),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: const Text("App is working! Now add your movies")),
        ],
      ),
    );
  }
}
