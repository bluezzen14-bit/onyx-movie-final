import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const OnyxMoviesApp());

class OnyxMoviesApp extends StatelessWidget {
  const OnyxMoviesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ONYX MOVIES',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0A0A0A)),
      home: const AuthCheck(),
    );
  }
}

// --- AUTH ---
class AuthService {
  static const adminEmails = ['mugabibenjamin14@gmail.com', 'rachetyaz900@gmail.com'];
  static const String usersKey = 'onyx_users';
  static const String currentUserKey = 'onyx_current_user';
  static Future<List<Map<String,dynamic>>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(usersKey);
    if (data == null) return [];
    return List<Map<String,dynamic>>.from(jsonDecode(data));
  }
  static Future<bool> register(String name, String email, String pass) async {
    email = email.toLowerCase().trim();
    var users = await getUsers();
    if (users.any((u) => u['email'] == email)) return false;
    users.add({'name': name, 'email': email, 'pass': pass});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(usersKey, jsonEncode(users));
    await prefs.setString(currentUserKey, email);
    return true;
  }
  static Future<bool> login(String email, String pass) async {
    email = email.toLowerCase().trim();
    var users = await getUsers();
    var found = users.where((u) => u['email'] == email && u['pass'] == pass);
    if (found.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(currentUserKey, email);
    return true;
  }
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(currentUserKey);
  }
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(currentUserKey);
  }
  static bool isAdmin(String email) => adminEmails.contains(email.toLowerCase().trim());
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService.getCurrentUser(),
      builder: (context, snap) {
        if (!snap.hasData) return const LoginScreen();
        if (snap.data == null) return const LoginScreen();
        if (AuthService.isAdmin(snap.data!)) return AdminPanel(email: snap.data!);
        return UserPanel(email: snap.data!);
      },
    );
  }
}

// --- LOGIN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  bool isLogin = true;
  bool loading = false;
  void handleAuth() async {
    setState(() => loading = true);
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
      setState(() => loading = false); return;
    }
    bool ok;
    if (isLogin) {
      ok = await AuthService.login(email, pass);
      if (!ok) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong email or password'))); setState(()=>loading=false); return; }
    } else {
      if (nameCtrl.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter name'))); setState(()=>loading=false); return; }
      ok = await AuthService.register(nameCtrl.text, email, pass);
      if (!ok) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email already registered'))); setState(()=>loading=false); return; }
    }
    if (!mounted) return;
    if (AuthService.isAdmin(email)) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminPanel(email: email)));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UserPanel(email: email)));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF0F0F0F)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.15))),
              child: Column(
                children: [
                  const Icon(Icons.movie_filter_rounded, size: 70, color: Color(0xFF9C27FF)),
                  const Text('ONYX MOVIES', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const Text('iOS 26 Liquid Glass Edition', style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 30),
                  if (!isLogin) TextField(controller: nameCtrl, decoration: _glassDec('Full Name', Icons.person)),
                  if (!isLogin) const SizedBox(height: 16),
                  TextField(controller: emailCtrl, decoration: _glassDec('Email', Icons.email_rounded)),
                  const SizedBox(height: 16),
                  TextField(controller: passCtrl, obscureText: true, decoration: _glassDec('Password', Icons.lock)),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: loading ? null : handleAuth,
                    child: loading ? const CircularProgressIndicator(color: Colors.white) : Text(isLogin ? 'LOGIN' : 'REGISTER', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  )),
                  const SizedBox(height: 16),
                  TextButton(onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(isLogin ? "Don't have account? Register" : "Have account? Login", style: const TextStyle(color: Colors.white70))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  InputDecoration _glassDec(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon, color: Colors.white54),
    filled: true, fillColor: Colors.white.withOpacity(0.06),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
  );
}

// --- MOVIE DATA ---
class Movie {
  final String title;
  final String category;
  final String year;
  final Color color;
  Movie(this.title, this.category, this.year, this.color);
}

final List<Movie> allMovies = [
  Movie('John Wick 4', 'Released', '2023', Colors.red),
  Movie('Avatar 2', 'Released', '2022', Colors.blue),
  Movie('Spider-Verse', 'Animations', '2023', Colors.purple),
  Movie('Kung Fu Panda 4', 'Animations', '2024', Colors.orange),
  Movie('Moana 2', 'Animations', '2024', Colors.teal),
  Movie('RRR', 'Indian Movies', '2022', Colors.deepOrange),
  Movie('Jawan', 'Indian Movies', '2023', Colors.amber),
  Movie('Animal', 'Indian Movies', '2023', Colors.brown),
  Movie('Stranger Things S5', 'Latest Series', '2025', Colors.redAccent),
  Movie('House of Dragon S2', 'Latest Series', '2024', Colors.black54),
  Movie('Loki S2', 'Latest Series', '2023', Colors.green),
  Movie('Deadpool & Wolverine', 'Latest Movies', '2024', Colors.red),
  Movie('Dune 2', 'Latest Movies', '2024', Colors.yellow),
  Movie('Inside Out 2', 'Latest Movies', '2024', Colors.pink),
];

// --- USER PANEL WITH CATEGORIES ---
class UserPanel extends StatefulWidget {
  final String email;
  const UserPanel({super.key, required this.email});
  @override
  State<UserPanel> createState() => _UserPanelState();
}
class _UserPanelState extends State<UserPanel> {
  String selectedCategory = 'Latest Movies';
  final categories = ['Latest Movies', 'Latest Series', 'Released', 'Animations', 'Indian Movies'];

  @override
  Widget build(BuildContext context) {
    final filtered = allMovies.where((m) => m.category == selectedCategory).toList();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('ONYX', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      Text('Hi, ${widget.email.split('@')[0]}', style: const TextStyle(color: Colors.white54)),
                    ]),
                    IconButton(onPressed: () async { await AuthService.logout(); if(context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginScreen())); }, icon: const Icon(Icons.logout_rounded, color: Colors.white70)),
                  ],
                ),
              ),
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final isSel = cat == selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF9C27FF) : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSel ? Colors.transparent : Colors.white.withOpacity(0.1)),
                        ),
                        child: Center(child: Text(cat, style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal))),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(selectedCategory, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final movie = filtered[i];
                    return Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.08))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(color: movie.color.withOpacity(0.5), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
                              child: Center(child: Icon(Icons.play_circle_fill_rounded, size: 50, color: Colors.white.withOpacity(0.9))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('${movie.category} • ${movie.year}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
                            ]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ADMIN PANEL ---
class AdminPanel extends StatelessWidget {
  final String email;
  const AdminPanel({super.key, required this.email});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ADMIN: $email'), backgroundColor: const Color(0xFF9C27FF)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('All Movies by Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...allMovies.map((m) => ListTile(
            leading: CircleAvatar(backgroundColor: m.color, child: const Icon(Icons.movie, color: Colors.white)),
            title: Text(m.title),
            subtitle: Text('${m.category} • ${m.year}'),
            trailing: const Icon(Icons.edit, color: Colors.white54),
          )),
          const SizedBox(height: 20),
          ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () async { await AuthService.logout(); if(context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginScreen())); }, icon: const Icon(Icons.logout), label: const Text('Logout')),
        ],
      ),
    );
  }
}
