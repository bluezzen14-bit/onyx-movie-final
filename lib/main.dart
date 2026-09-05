import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const OnyxApp());

const String appVersion = "1.0.4";
const skyBlue = Color(0xFF38BDF8);
const skyBlueDeep = Color(0xFF0EA5E9);
const skyBlueLight = Color(0xFF7DD3FC);

// --- Liquid Glass Widget iOS 26 Style ---
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final double radius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  const LiquidGlass({super.key, required this.child, this.blur=25, this.radius=28, this.color, this.padding});
  @override
  Widget build(BuildContext context){
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withOpacity(0.12),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.05)]
            ),
            boxShadow: [BoxShadow(color: skyBlue.withOpacity(0.15), blurRadius: 30, spreadRadius: 1)],
          ),
          child: child,
        ),
      ),
    );
  }
}

class MovieModel {
  final String title, category, vj, url; final Color color;
  MovieModel({required this.title, required this.category, required this.vj, required this.url, required this.color});
}
List<MovieModel> movies = [
  MovieModel(title: "John Wick 4", category: "Action", vj: "VJ Junior", url: "https://test-videos.co.uk/vids/sintel/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4", color: skyBlue),
  MovieModel(title: "Lwasa Ne Namatovu", category: "Comedy", vj: "VJ Jingo", url: "https://test-videos.co.uk/vids/sintel/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4", color: skyBlueDeep),
  MovieModel(title: "Black Panther", category: "Action", vj: "VJ Emmy", url: "https://test-videos.co.uk/vids/sintel/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4", color: skyBlueLight),
];

class OnyxApp extends StatelessWidget {
  const OnyxApp({super.key});
  @override Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false, title: "ONYX MOVIES",
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: const Color(0xFF020617), colorScheme: ColorScheme.fromSeed(seedColor: skyBlue, brightness: Brightness.dark)),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget{ const AuthGate({super.key}); @override State<AuthGate> createState()=>_AuthGateState(); }
class _AuthGateState extends State<AuthGate>{
  @override void initState(){ super.initState(); _check(); }
  _check() async { final p=await SharedPreferences.getInstance(); final u=p.getString('onyx_user'); if(u!=null && mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomeIOS26())); }
  @override Widget build(BuildContext context)=>const LoginIOS26();
}

// --- LOGIN with Liquid Glass + Sky Blue ---
class LoginIOS26 extends StatefulWidget{ const LoginIOS26({super.key}); @override State<LoginIOS26> createState()=>_LoginIOS26State(); }
class _LoginIOS26State extends State<LoginIOS26>{
  final _u=TextEditingController(), _p=TextEditingController(); bool loading=false;
  _login() async {
    setState(()=>loading=true); await Future.delayed(const Duration(seconds: 1));
    final prefs=await SharedPreferences.getInstance();
    if(_u.text.isNotEmpty){ await prefs.setString('onyx_user', _u.text); if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomeIOS26())); }
    setState(()=>loading=false);
  }
  @override Widget build(BuildContext context){
    return Scaffold(body: Stack(children: [
      // Sky blue gradient background iOS 26
      Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment.topLeft, radius: 1.4, colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9), Color(0xFF020617), Color(0xFF020617)]))),
      Positioned(top: -80, left: -80, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: skyBlue.withOpacity(0.4), boxShadow: [BoxShadow(color: skyBlue.withOpacity(0.5), blurRadius: 80)]))),
      Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: LiquidGlass(padding: const EdgeInsets.all(28), child: Column(children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(shape: BoxShape.circle, color: skyBlue.withOpacity(0.2), border: Border.all(color: Colors.white24)), child: const Icon(Icons.play_circle_fill_rounded, size: 56, color: skyBlue)),
        const SizedBox(height: 14), const Text("ONYX MOVIES", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.white)), Text("Liquid Glass • iOS 26 • v$appVersion", style: const TextStyle(color: skyBlueLight, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 28),
        TextField(controller: _u, style: const TextStyle(color: Colors.white), decoration: _glassInput("Username / Email", Icons.person_rounded)),
        const SizedBox(height: 14),
        TextField(controller: _p, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _glassInput("Password", Icons.lock_rounded)),
        const SizedBox(height: 22),
        SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: loading?null:_login, style: ElevatedButton.styleFrom(backgroundColor: skyBlue, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0), child: loading?const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)):const Text("Continue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("No account?", style: TextStyle(color: Colors.white54)), TextButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const RegisterIOS26())), child: const Text("Register", style: TextStyle(color: skyBlueLight, fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 10),
        TextButton(onPressed: () async { const url="https://github
