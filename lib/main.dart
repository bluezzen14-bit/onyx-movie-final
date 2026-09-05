import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const OnyxApp());

const skyBlue = Color(0xFF38BDF8);
const skyDeep = Color(0xFF0EA5E9);
const appVersion = "1.0.4";

class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  const LiquidGlass({super.key, required this.child, this.radius = 24});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class OnyxApp extends StatelessWidget {
  const OnyxApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF020617)),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final u = TextEditingController();
  final p = TextEditingController();
  bool loading = false;

  login() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1));
    final pref = await SharedPreferences.getInstance();
    await pref.setString('user', u.text);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF020617)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: LiquidGlass(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.play_circle_fill_rounded, size: 60, color: skyBlue),
                    const SizedBox(height: 12),
                    const Text("ONYX MOVIES", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Text("Liquid Glass iOS 26 - v1.0.4", style: TextStyle(color: skyBlue, fontSize: 12)),
                    const SizedBox(height: 24),
                    TextField(controller: u, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Username", filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                    const SizedBox(height: 12),
                    TextField(controller: p, obscureText: true, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Password", filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                    const SizedBox(height: 20),
                    SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: loading ? null : login, style: ElevatedButton.styleFrom(backgroundColor: skyBlue, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: loading ? const CircularProgressIndicator() : const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)))),
                    const SizedBox(height: 12),
                    TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text("Create Account - Register", style: TextStyle(color: skyBlue))),
                    TextButton(onPressed: () async { final uri = Uri.parse("https://github.com/bluezzer/onyx-movie-final/releases"); if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }, child: const Text("Check Update", style: TextStyle(color: Colors.white38, fontSize: 11))),
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final u = TextEditingController();
  final e = TextEditingController();
  final p = TextEditingController();
  bool loading = false;

  register() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1));
    final pref = await SharedPreferences.getInstance();
    await pref.setString('user', u.text);
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false);
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text("Register")),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF020617)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: LiquidGlass(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text("Create Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 20),
                    TextField(controller: u, decoration: InputDecoration(hintText: "Username", filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                    const SizedBox(height: 12),
                    TextField(controller: e, decoration: InputDecoration(hintText: "Email", filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                    const SizedBox(height: 12),
                    TextField(controller: p, obscureText: true, decoration: InputDecoration(hintText: "Password", filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                    const SizedBox(height: 20),
                    SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: loading ? null : register, style: ElevatedButton.styleFrom(backgroundColor: skyBlue, foregroundColor: Colors.black), child: loading ? const CircularProgressIndicator() : const Text("REGISTER"))),
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(backgroundColor: skyBlue, foregroundColor: Colors.black, title: const Text("ONYX v1.0.4 Sky Blue")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        children: [
          LiquidGlass(child: Container(height: 160, decoration: BoxDecoration(color: skyBlue.withOpacity(0.3), borderRadius: BorderRadius.circular(24)), child: const Center(child: Icon(Icons.play_circle_fill_rounded, size: 50, color: Colors.white)))),
          LiquidGlass(child: Container(height: 160, decoration: BoxDecoration(color: skyDeep.withOpacity(0.3), borderRadius: BorderRadius.circular(24)), child: const Center(child: Icon(Icons.movie_rounded, size: 50, color: Colors.white)))),
        ],
      ),
    );
  }
}
