import 'package:flutter/material.dart';
import '../widgets/liquid_glass.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("ONYX MOVIES"), backgroundColor: Colors.black),
      body: Center(
        child: LiquidGlass(
          child: const Text("Premium Movies & Series - iOS 26 Liquid Glass", 
          style: TextStyle(color: Colors.white))
        )
      )
    );
  }
}
