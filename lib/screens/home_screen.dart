import 'package:flutter/material.dart';
import '../widgets/liquid_glass.dart';
import 'player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            title: const Text("ONYX MOVIES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            floating: true,
          ),
          SliverToBoxAdapter(
            child: LiquidGlass(
              blur: 30, opacity: 0.15,
              child: const Text("Premium Movies & Series", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
