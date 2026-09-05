‎import 'dart:ui';
‎import 'package:flutter/material.dart';
‎import 'package:flutter/cupertino.dart';
‎import 'package:shared_preferences/shared_preferences.dart';
‎import 'package:url_launcher/url_launcher.dart';
‎import 'package:firebase_core/firebase_core.dart';
‎import 'package:firebase_database/firebase_database.dart';
‎import 'package:share_plus/share_plus.dart';
‎
‎const skyBlue = Color(0xFF38BDF8);
‎const skyDeep = Color(0xFF0EA5E9);
‎
‎Future<void> main() async {
‎  WidgetsFlutterBinding.ensureInitialized();
‎  await Firebase.initializeApp(
‎    options: const FirebaseOptions(
‎      apiKey: "AIzaSyAqhqupsd2veboIOFZfIjaNNOKpKxlV2MI",
‎      authDomain: "onyx-movies-2b58b.firebaseapp.com",
‎      databaseURL: "https://onyx-movies-2b58b-default-rtdb.firebaseio.com",
‎      projectId: "onyx-movies-2b58b",
‎      storageBucket: "onyx-movies-2b58b.firebasestorage.app",
‎      messagingSenderId: "243702982500",
‎      appId: "1:243702982500:web:a65b9c59dd2e06c3ec7c71",
‎    ),
‎  );
‎  runApp(const MyApp());
‎}
‎
‎Widget iphoneLoad() {
‎  return const CupertinoActivityIndicator(
‎    radius: 9,
‎    color: Colors.white70,
‎  );
‎}
‎
‎class LiquidGlass extends StatelessWidget {
‎  final Widget child;
‎  const LiquidGlass({Key? key, required this.child}) : super(key: key);
‎  @override
‎  Widget build(BuildContext context) {
‎    return ClipRRect(
‎      borderRadius: BorderRadius.circular(20),
‎      child: BackdropFilter(
‎        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
‎        child: Container(
‎          decoration: BoxDecoration(
‎            color: Colors.white.withOpacity(0.10),
‎            borderRadius: BorderRadius.circular(20),
‎            border: Border.all(
‎              color: Colors.white.withOpacity(0.18),
‎            ),
‎          ),
‎          child: child,
‎        ),
‎      ),
‎    );
‎  }
‎}
‎
‎class MyApp extends StatelessWidget {
‎  const MyApp({Key? key}) : super(key: key);
‎  @override
‎  Widget build(BuildContext context) {
‎    return MaterialApp(
‎      debugShowCheckedModeBanner: false,
‎      theme: ThemeData.dark(),
‎      home: const LoginPage(),
‎    );
‎  }
‎}
‎
‎class LoginPage extends StatefulWidget {
‎  const LoginPage({Key? key}) : super(key: key);
‎  @override
‎  State<LoginPage> createState() => _LoginPageState();
‎}
‎
‎class _LoginPageState extends State<LoginPage> {
‎  final u = TextEditingController();
‎  bool loading = false;
‎  @override
‎  Widget build(BuildContext context) {
‎    return Scaffold(
‎      body: Container(
‎        decoration: const BoxDecoration(
‎          gradient: LinearGradient(
‎            colors: [skyDeep, Color(0xFF020617)],
‎            begin: Alignment.topCenter,
‎            end: Alignment.bottomCenter,
‎          ),
‎        ),
‎        child: Center(
‎          child: SingleChildScrollView(
‎            padding: const EdgeInsets.all(24),
‎            child: LiquidGlass(
‎              child: Padding(
‎                padding: const EdgeInsets.all(24),
‎                child: Column(
‎                  children: [
‎                    const Icon(
‎                      Icons.play_circle_fill_rounded,
‎                      size: 64,
‎                      color: skyBlue,
‎                    ),
‎                    const SizedBox(height: 12),
‎                    const Text(
‎                      "ONYX MOVIES",
‎                      style: TextStyle(
‎                        fontSize: 24,
‎                        fontWeight: FontWeight.bold,
‎                        color: Colors.white,
‎                      ),
‎                    ),
‎                    const Text(
‎                      "Liquid Glass iOS 26 Sky Blue",
‎                      style: TextStyle(
‎                        color: skyBlue,
‎                        fontSize: 11,
‎                      ),
‎                    ),
‎                    const SizedBox(height: 20),
‎                    TextField(
‎                      controller: u,
‎                      style: const TextStyle(color: Colors.white),
‎                      decoration: InputDecoration(
‎                        hintText: "Email",
‎                        filled: true,
‎                        fillColor: Colors.white.withOpacity(0.08),
‎                        border: OutlineInputBorder(
‎                          borderRadius: BorderRadius.circular(14),
‎                        ),
‎                      ),
‎                    ),
‎                    const SizedBox(height: 20),
‎                    SizedBox(
‎                      width: double.infinity,
‎                      height: 50,
‎                      child: ElevatedButton(
‎                        onPressed: () async {
‎                          setState(() {
‎                            loading = true;
‎                          });
‎                          final p = await SharedPreferences.getInstance();
‎                          await p.setString('user', u.text);
‎                          await Future.delayed(
‎                            const Duration(seconds: 1),
‎                          );
‎                          if (mounted) {
‎                            Navigator.pushReplacement(
‎                              context,
‎                              MaterialPageRoute(
‎                                builder: (_) => const HomePage(),
‎                              ),
‎                            );
‎                          }
‎                          setState(() {
‎                            loading = false;
‎                          });
‎                        },
‎                        style: ElevatedButton.styleFrom(
‎                          backgroundColor: skyBlue,
‎                          foregroundColor: Colors.black,
‎                        ),
‎                        child: loading
‎                            ? iphoneLoad()
‎                            : const Text("LOGIN"),
‎                      ),
‎                    ),
‎                    TextButton(
‎                      onPressed: () {
‎                        Navigator.push(
‎                          context,
‎                          MaterialPageRoute(
‎                            builder: (_) => const AdminPage(),
‎                          ),
‎                        );
‎                      },
‎                      child: const Text(
‎                        "Admin Panel",
‎                        style: TextStyle(color: Colors.white38),
‎                      ),
‎                    ),
‎                  ],
‎                ),
‎              ),
‎            ),
‎          ),
‎        ),
‎      ),
‎    );
‎  }
‎}
‎
‎class HomePage extends StatelessWidget {
‎  const HomePage({Key? key}) : super(key: key);
‎  @override
‎  Widget build(BuildContext context) {
‎    return Scaffold(
‎      backgroundColor: const Color(0xFF020617),
‎      appBar: AppBar(
‎        backgroundColor: skyBlue,
‎        title: const Text(
‎          "ONYX - Sky Blue",
‎          style: TextStyle(color: Colors.black),
‎        ),
‎      ),
‎      bottomNavigationBar: BottomNavigationBar(
‎        backgroundColor: Colors.black,
‎        selectedItemColor: skyBlue,
‎        unselectedItemColor: Colors.white54,
‎        type: BottomNavigationBarType.fixed,
‎        items: const [
‎          BottomNavigationBarItem(
‎            icon: Icon(Icons.home_rounded),
‎            label: "Home",
‎          ),
‎          BottomNavigationBarItem(
‎            icon: Icon(Icons.movie_rounded),
‎            label: "Movies",
‎          ),
‎          BottomNavigationBarItem(
‎            icon: Icon(Icons.download_rounded),
‎            label: "Downloads",
‎          ),
‎          BottomNavigationBarItem(
‎            icon: Icon(Icons.person_rounded),
‎            label: "Profile",
‎          ),
‎        ],
‎      ),
‎      body: ListView(
‎        padding: const EdgeInsets.all(16),
‎        children: [
‎          const LiquidGlass(
‎            child: SizedBox(
‎              height: 50,
‎              child: Padding(
‎                padding: EdgeInsets.symmetric(horizontal: 14),
‎                child: Row(
‎                  children: [
‎                    Icon(Icons.search_rounded, color: skyBlue),
‎                    SizedBox(width: 8),
‎                    Text(
‎                      "Search liquid glass transparent",
‎                      style: TextStyle(
‎                        color: Colors.white38,
‎                        fontSize: 12,
‎                      ),
‎                    ),
‎                  ],
‎                ),
‎              ),
‎            ),
‎          ),
‎          const SizedBox(height: 16),
‎          LiquidGlass(
‎            child: Container(
‎              height: 180,
‎              decoration: BoxDecoration(
‎                color: skyBlue.withOpacity(0.2),
‎                borderRadius: BorderRadius.circular(20),
‎              ),
‎              child: const Center(
‎                child: Text(
‎                  "Banner 7 Latest Movies",
‎                  style: TextStyle(color: Colors.white),
‎                ),
‎              ),
‎            ),
‎          ),
‎          const SizedBox(height: 16),
‎          const Text(
‎            "Latest Release",
‎            style: TextStyle(
‎              color: Colors.white,
‎              fontWeight: FontWeight.bold,
‎            ),
‎          ),
‎          const SizedBox(height: 8),
‎          SizedBox(
‎            height: 120,
‎            child: ListView.separated(
‎              scrollDirection: Axis.horizontal,
‎              itemCount: 5,
‎              separatorBuilder: (_, __) => const SizedBox(width: 10),
‎              itemBuilder: (_, i) => LiquidGlass(
‎                child: Container(
‎                  width: 90,
‎                  decoration: BoxDecoration(
‎                    color: skyBlue.withOpacity(0.2),
‎                    borderRadius: BorderRadius.circular(16),
‎                  ),
‎                  child: Stack(
‎                    children: [
‎                      const Center(
‎                        child: Icon(Icons.play_circle_fill_rounded,
‎                            color: Colors.white),
‎                      ),
‎                      Positioned(
‎                        top: 6,
‎                        right: 6,
‎                        child: Container(
‎                          padding: const EdgeInsets.symmetric(
‎                              horizontal: 5, vertical: 2),
‎                          decoration: BoxDecoration(
‎                            color: skyBlue,
‎                            borderRadius: BorderRadius.circular(6),
‎                          ),
‎                          child: const Text(
‎                            "VJ Junior",
‎                            style: TextStyle(
‎                              fontSize: 7,
‎                              color: Colors.black,
‎                              fontWeight: FontWeight.bold,
‎                            ),
‎                          ),
‎                        ),
‎                      ),
‎                    ],
‎                  ),
‎                ),
‎              ),
‎            ),
‎          ),
‎        ],
‎      ),
‎    );
‎  }
‎}
‎
‎class AdminPage extends StatefulWidget {
‎  const AdminPage({Key? key}) : super(key: key);
‎  @override
‎  State<AdminPage> createState() => _AdminPageState();
‎}
‎
‎class _AdminPageState extends State<AdminPage> {
‎  final t = TextEditingController();
‎  final vj = TextEditingController();
‎  bool up = false;
‎  @override
‎  Widget build(BuildContext context) {
‎    return Scaffold(
‎      appBar: AppBar(
‎        backgroundColor: skyBlue,
‎        title: const Text("Admin Dashboard"),
‎      ),
‎      body: Padding(
‎        padding: const EdgeInsets.all(16),
‎        child: Column(
‎          children: [
‎            TextField(
‎              controller: t,
‎              decoration: const InputDecoration(labelText: "Movie Title"),
‎            ),
‎            const SizedBox(height: 8),
‎            TextField(
‎              controller: vj,
‎              decoration: const InputDecoration(labelText: "VJ Name"),
‎            ),
‎            const SizedBox(height: 16),
‎            SizedBox(
‎              width: double.infinity,
‎              height: 50,
‎              child: ElevatedButton(
‎                onPressed: () async {
‎                  setState(() => up = true);
‎                  final ref = FirebaseDatabase.instance
‎                      .ref()
‎                      .child('movies')
‎                      .push();
‎                  await ref.set({
‎                    'title': t.text,
‎                    'vj': vj.text,
‎                    'timestamp': DateTime.now().millisecondsSinceEpoch,
‎                  });
‎                  setState(() => up = false);
‎                  if (mounted) {
‎                    ScaffoldMessenger.of(context).showSnackBar(
‎                      const SnackBar(
‎                        content: Text("Uploaded to Firebase!"),
‎                      ),
‎                    );
‎                  }
‎                },
‎                style: ElevatedButton.styleFrom(
‎                  backgroundColor: skyBlue,
‎                ),
‎                child: up ? iphoneLoad() : const Text("UPLOAD"),
‎              ),
‎            ),
‎          ],
‎        ),
‎      ),
‎    );
‎  }
‎}
