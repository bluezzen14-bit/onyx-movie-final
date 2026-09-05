import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // for auto-update download

void main() => runApp(const OnyxMoviesApp());

// --- APP VERSION - CHANGE THIS WHEN YOU UPDATE APP ---
const String currentAppVersion = "1.0.3";
const String remoteAppVersion = "1.0.4"; // Change to higher to trigger update popup
const String updateDownloadLink = "https://github.com/bluezzer/onyx-movie-final/releases"; // Your APK link

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

// --- iPhone Small Colorless Loading ---
Widget iphoneLoading({double size = 18}) {
  return SizedBox(
    width: size,
    height: size,
    child: const CupertinoActivityIndicator(radius: 9, color: Color(0x88FFFFFF)),
  );
}

// --- AUTO UPDATE SERVICE (NEW UPDATE) ---
class AutoUpdateService {
  static bool isUpdateAvailable() {
    // Compare versions: 1.0.3 vs 1.0.4
    return remoteAppVersion!= currentAppVersion;
  }

  static void checkForUpdate(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2)); // Wait for app to load
    if (!context.mounted) return;
    if (isUpdateAvailable()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [Icon(Icons.system_update_rounded, color: Color(0xFF9C27FF)), SizedBox(width: 10), Text('Update Available')]),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('New version $remoteAppVersion is available!', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Current: $currentAppVersion → New: $remoteAppVersion', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 12),
            const Text('• Bug fixes\n• New movies added\n• Better performance', style: TextStyle(fontSize: 13)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later', style: TextStyle(color: Colors.white54))),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27FF)), onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(updateDownloadLink);
              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
            }, child: Text('UPDATE NOW to $remoteAppVersion')),
          ],
        ),
      );
    }
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
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(backgroundColor: const Color(0xFF0A0A0A), body: Center(child: iphoneLoading(size: 20)));
        }
        if (!snap.hasData || snap.data == null) return const LoginScreen();
        if (AuthService.isAdmin(snap.data!)) return AdminPanel(email: snap.data!);
        return UserPanel(email: snap.data!);
      },
    );
  }
}

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
    await Future.delayed(const Duration(milliseconds: 800));
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields'))); setState(() => loading = false); return; }
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
    if (AuthService.isAdmin(email)) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminPanel(email: email))); } else { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UserPanel(email: email))); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF0F0F0F)], begin: Alignment.topLeft, end: Alignment.bottomRight)), child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.15))), child: Column(children: [const Icon(Icons.movie_filter_rounded, size: 70, color: Color(0xFF9C27FF)), const Text('ONYX MOVIES', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)), Text('v$currentAppVersion • iOS 26 Liquid Glass', style: const TextStyle(color: Colors.white54, fontSize: 12)), const SizedBox(height: 30), if (!isLogin) TextField(controller: nameCtrl, decoration: _glassDec('Full Name', Icons.person)), if (!isLogin) const SizedBox(height: 16), TextField(controller: emailCtrl, decoration: _glassDec('Email', Icons.email_rounded)), const SizedBox(height: 16), TextField(controller: passCtrl, obscureText: true, decoration: _glassDec('Password', Icons.lock)), const SizedBox(height: 24), SizedBox(width: double.infinity, height: 52, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: loading? null : handleAuth, child: loading? iphoneLoading() : Text(isLogin? 'LOGIN' : 'REGISTER', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))), const SizedBox(height: 16), TextButton(onPressed: () => setState(() => isLogin =!isLogin), child: Text(isLogin? "Don't have account? Register" : "Have account? Login", style: const TextStyle(color: Colors.white70)))]))))));
  }
  InputDecoration _glassDec(String label, IconData icon) => InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.white54), filled: true, fillColor: Colors.white.withOpacity(0.06), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none));
}

class Movie {
  final String title;
  final String category;
  final String year;
  final String videoUrl;
  final String vjName;
  final Color color;
  Movie(this.title, this.category, this.year, this.videoUrl, this.vjName, this.color);
}

final List<Movie> allMovies = [
  Movie('John Wick 4', 'Released', '2023', 'https://sample.mp4', 'VJ Junior', Colors.red),
  Movie('Avatar 2', 'Released', '2022', 'https://sample.mp4', 'VJ Ice P', Colors.blue),
  Movie('Spider-Verse', 'Animations', '2023', 'https://sample.mp4', 'VJ Junior', Colors.purple),
  Movie('Kung Fu Panda 4', 'Animations', '2024', 'https://sample.mp4', 'VJ Little', Colors.orange),
  Movie('RRR', 'Indian Movies', '2022', 'https://sample.mp4', 'VJ Junior', Colors.deepOrange),
  Movie('Jawan', 'Indian Movies', '2023', 'https://sample.mp4', 'VJ Ice P', Colors.amber),
  Movie('Stranger Things S5', 'Latest Series', '2025', 'https://sample.mp4', 'VJ Junior', Colors.redAccent),
  Movie('House of Dragon S2', 'Latest Series', '2024', 'https://sample.mp4', 'VJ Ice P', Colors.black54),
  Movie('Deadpool 3', 'Latest Movies', '2024', 'https://sample.mp4', 'VJ Junior', Colors.red),
  Movie('Dune 2', 'Latest Movies', '2024', 'https://sample.mp4', 'VJ Ice P', Colors.yellow),
];

final List<String> vjList = ['VJ Junior', 'VJ Ice P', 'VJ Little', 'VJ Emmy', 'VJ Jingo', 'VJ Mox'];

// --- USER PANEL WITH AUTO UPDATE CHECK ---
class UserPanel extends StatefulWidget {
  final String email;
  const UserPanel({super.key, required this.email});
  @override
  State<UserPanel> createState() => _UserPanelState();
}
class _UserPanelState extends State<UserPanel> {
  String selectedCategory = 'Latest Movies';
  final categories = ['Latest Movies', 'Latest Series', 'Released', 'Animations', 'Indian Movies'];
  bool isLoadingMovies = false;

  @override
  void initState() {
    super.initState();
    // AUTO UPDATE CHECK INSIDE APP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AutoUpdateService.checkForUpdate(context);
    });
  }

  void loadCategory(String cat) async {
    setState(() { isLoadingMovies = true; selectedCategory = cat; });
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => isLoadingMovies = false);
  }

  void downloadMovie(Movie movie) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading ${movie.title} (${movie.vjName})...'))); }

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
              Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('ONYX', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2)), Text('Hi, ${widget.email.split('@')[0]} • v$currentAppVersion', style: const TextStyle(color: Colors.white54, fontSize: 12))]), IconButton(onPressed: () async { await AuthService.logout(); if(context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginScreen())); }, icon: const Icon(Icons.logout_rounded, color: Colors.white70))])),
              SizedBox(height: 45, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: categories.length, itemBuilder: (context, i) { final cat = categories[i]; final isSel = cat == selectedCategory; return GestureDetector(onTap: () => loadCategory(cat), child: Container(margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: isSel? const Color(0xFF9C27FF) : Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20)), child: Center(child: Text(cat, style: TextStyle(fontWeight: isSel? FontWeight.bold : FontWeight.normal))))); })),
              const SizedBox(height: 20),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [Text(selectedCategory, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(width: 12), if (isLoadingMovies) iphoneLoading(size: 16)])),
              const SizedBox(height: 12),
              Expanded(child: isLoadingMovies? Center(child: iphoneLoading(size: 22)) : GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: filtered.length, itemBuilder: (context, i) { final movie = filtered[i]; return GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie))), child: Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.08))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Stack(children: [Container(decoration: BoxDecoration(color: movie.color.withOpacity(0.5), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))), child: Center(child: Icon(Icons.play_circle_fill_rounded, size: 50, color: Colors.white.withOpacity(0.9)))), Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF9C27FF), borderRadius: BorderRadius.circular(8)), child: Text(movie.vjName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))), Positioned(top: 8, left: 8, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.download_rounded, size: 16, color: Colors.white)))] )), Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${movie.category} • ${movie.vjName}', style: const TextStyle(fontSize: 10, color: Colors.white54))]))] ) ); }))),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerScreen extends StatelessWidget {
  final Movie movie;
  const PlayerScreen({super.key, required this.movie});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(movie.title), backgroundColor: Colors.black), body: Column(children: [Stack(children: [Container(height: 220, color: movie.color.withOpacity(0.5), child: const Center(child: Icon(Icons.play_circle_fill, size: 80, color: Colors.white))), Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF9C27FF), borderRadius: BorderRadius.circular(12)), child: Text(movie.vjName, style: const TextStyle(fontWeight: FontWeight.bold))))]), Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(movie.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text('${movie.category} • ${movie.year} • ${movie.vjName}', style: const TextStyle(color: Colors.white54)), const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27FF)), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saving ${movie.title} [${movie.vjName}] to Gallery'))); }, icon: const Icon(Icons.download), label: const Text('DOWNLOAD')))]))]));
  }
}

class AdminPanel extends StatefulWidget {
  final String email;
  const AdminPanel({super.key, required this.email});
  @override
  State<AdminPanel> createState() => _AdminPanelState();
}
class _AdminPanelState extends State<AdminPanel> {
  final titleCtrl = TextEditingController();
  final vjCtrl = TextEditingController();
  final versionCtrl = TextEditingController(text: remoteAppVersion);
  String selectedVJ = 'VJ Junior';
  String selectedCat = 'Latest Movies';
  final categories = ['Latest Movies', 'Latest Series', 'Released', 'Animations', 'Indian Movies'];
  void addMovie() { if (titleCtrl.text.isEmpty) return; setState(() { allMovies.add(Movie(titleCtrl.text, selectedCat, '2024', 'https://sample.mp4', selectedVJ, Colors.primaries[allMovies.length % Colors.primaries.length])); titleCtrl.clear(); }); }
  void addVJ() { if (vjCtrl.text.isEmpty) return; setState(() { vjList.add(vjCtrl.text); selectedVJ = vjCtrl.text; vjCtrl.clear(); }); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('ADMIN v$currentAppVersion'), backgroundColor: const Color(0xFF9C27FF)), body: ListView(padding: const EdgeInsets.all(16), children: [const Text('AUTO UPDATE CONTROL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)), const SizedBox(height: 10), Row(children: [Expanded(child: TextField(controller: versionCtrl, decoration: InputDecoration(hintText: 'New version e.g. 1.0.5', filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))), const SizedBox(width: 10), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update version set to ${versionCtrl.text} - Users will see popup!'))); }, child: const Text('PUSH UPDATE'))]), const Divider(height: 30), const Text('UPLOAD VJs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9C27FF))), const SizedBox(height: 10), Row(children: [Expanded(child: TextField(controller: vjCtrl, decoration: InputDecoration(hintText: 'New VJ name', filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))), const SizedBox(width: 10), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27FF)), onPressed: addVJ, child: const Text('ADD VJ'))]), const Divider(height: 30), const Text('UPLOAD MOVIE WITH VJ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 12), TextField(controller: titleCtrl, decoration: InputDecoration(hintText: 'Movie Title', filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))), const SizedBox(height: 12), DropdownButtonFormField<String>(value: selectedVJ, decoration: InputDecoration(filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), labelText: 'VJ Name'), items: vjList.map((vj) => DropdownMenuItem(value: vj, child: Text(vj))).toList(), onChanged: (v) => setState(()=>selectedVJ=v!)), const SizedBox(height: 12), DropdownButtonFormField<String>(value: selectedCat, decoration: InputDecoration(filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), labelText: 'Category'), items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(()=>selectedCat=v!)), const SizedBox(height: 12), SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27FF)), onPressed: addMovie, icon: const Icon(Icons.upload), label: Text('UPLOAD WITH $selectedVJ'))), const SizedBox(height: 20), ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () async { await AuthService.logout(); if(context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginScreen())); }, icon: const Icon(Icons.logout), label: const Text('Logout'))]));
  }
}
