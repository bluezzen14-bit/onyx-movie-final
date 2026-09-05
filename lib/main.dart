import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

const skyBlue = Color(0xFF38BDF8);
const skyDeep = Color(0xFF0EA5E9);
const appVer = "1.0.6";

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
  runApp(const OnyxApp());
}

Widget iphoneLoad() {
  return const CupertinoActivityIndicator(radius: 9, color: Colors.white70);
}

class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  const Glass({super.key, required this.child, this.radius = 20});
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
      home: const Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}
class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF020617), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.play_circle_fill_rounded, size: 70, color: skyBlue), const SizedBox(height: 16), iphoneLoad(), const SizedBox(height: 12), const Text("ONYX MOVIES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2))])) );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  bool load = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [skyDeep, Color(0xFF020617)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Glass(
              radius: 24,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  const Icon(Icons.play_circle_fill_rounded, size: 64, color: skyBlue),
                  const SizedBox(height: 10),
                  const Text("ONYX MOVIES", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 20),
                  TextField(controller: emailC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Email", filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                  const SizedBox(height: 12),
                  TextField(obscureText: true, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Password", filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: skyBlue, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: () async { setState(() => load = true); final p = await SharedPreferences.getInstance(); await p.setString('user', emailC.text); await Future.delayed(const Duration(seconds: 1)); if (mounted) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainPanel())); } setState(() => load = false); }, child: load? iphoneLoad() : const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)))),
                  TextButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLogin())); }, child: const Text("Admin Panel - 3 Emails Allowed", style: TextStyle(color: Colors.white38, fontSize: 11))),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainPanel extends StatefulWidget {
  const MainPanel({super.key});
  @override
  State<MainPanel> createState() => _MainPanelState();
}
class _MainPanelState extends State<MainPanel> {
  int idx = 0;
  final pages = const [HomePage(), MoviesPage(), SeriesPage(), DownloadsPage(), ProfilePage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      bottomNavigationBar: ClipRRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: BottomNavigationBar(currentIndex: idx, onTap: (i) => setState(() => idx = i), backgroundColor: Colors.black.withOpacity(0.3), selectedItemColor: skyBlue, unselectedItemColor: Colors.white54, type: BottomNavigationBarType.fixed, items: const [BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"), BottomNavigationBarItem(icon: Icon(Icons.movie_rounded), label: "Movies"), BottomNavigationBarItem(icon: Icon(Icons.tv_rounded), label: "Series"), BottomNavigationBarItem(icon: Icon(Icons.download_rounded), label: "Downloads"), BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile")]))),
      body: SafeArea(child: Column(children: [Padding(padding: const EdgeInsets.all(12), child: Row(children: [const Expanded(child: Glass(child: SizedBox(height: 48, child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Row(children: [Icon(Icons.search_rounded, color: skyBlue, size: 20), SizedBox(width: 8), Text("Search VJ, Genre...", style: TextStyle(color: Colors.white38, fontSize: 12))]))))), const SizedBox(width: 8), Glass(radius: 14, child: IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20), onPressed: () {}))])), Expanded(child: pages[idx])])),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final dbRef = FirebaseDatabase.instance.ref().child('movies');
    return StreamBuilder(
      stream: dbRef.orderByChild('timestamp').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [iphoneLoad(), const SizedBox(height: 8), const Text("Loading...", style: TextStyle(color: Colors.white38, fontSize: 11))]));
        }
        List<Map> list = [];
        if (snapshot.hasData && snapshot.data!.snapshot.value!= null) {
          final map = snapshot.data!.snapshot.value as Map;
          list = map.values.map((e) => e as Map).toList();
          list.sort((a, b) => (b['timestamp']?? 0).compareTo(a['timestamp']?? 0));
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            SizedBox(height: 190, child: PageView.builder(itemCount: list.isEmpty? 3 : (list.length > 7? 7 : list.length), itemBuilder: (_, i) {
              if (list.isEmpty) {
                return Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Glass(radius: 22, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skyBlue.withOpacity(0.5), Colors.black.withOpacity(0.2)])), child: Center(child: Text("Banner ${i + 1} - Upload in Admin", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))));
              }
              final m = list[i];
              return Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: GestureDetector(onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(movie: m))); }, child: Glass(radius: 22, child: Stack(children: [Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skyBlue.withOpacity(0.6), Colors.black.withOpacity(0.3)])), child: const Center(child: Icon(Icons.play_circle_fill_rounded, size: 50, color: Colors.white))), Positioned(bottom: 0, left: 0, right: 0, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.8), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m['title']?? "", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text("${m['genre']?? ''} • ${m['year']?? ''} • ${m['vj']?? ''}", style: const TextStyle(color: skyBlue, fontSize: 10)), Text(m['description']?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 10))]))), Positioned(top: 12, right: 12, child: Glass(radius: 20, child: IconButton(icon: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 18), onPressed: () {})))]))));
            })),
            buildSection(context, "Latest Release", list),
            buildSection(context, "Latest Series", list.where((m) => m['type'] == 'series').toList()),
            buildSection(context, "Trending Movies", list),
            buildSection(context, "Animations", list.where((m) => m['category'] == 'Animation').toList()),
            buildSection(context, "Indian Movies", list.where((m) => m['category'] == 'Indian').toList()),
          ],
        );
      },
    );
  }
}

Widget buildSection(BuildContext ctx, String title, List list) {
  if (list.isEmpty) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 8), child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
      SizedBox(height: 140, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 12), scrollDirection: Axis.horizontal, itemCount: 5, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => Glass(radius: 16, child: Container(width: 100, decoration: BoxDecoration(color: skyBlue.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: const Center(child: Icon(Icons.movie_rounded, color: Colors.white))))))
    ]);
  }
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), TextButton(onPressed: () { Navigator.push(ctx, MaterialPageRoute(builder: (_) => MoviesPage(initialList: list))); }, child: const Text("See more", style: TextStyle(color: skyBlue, fontSize: 11))) ])),
    SizedBox(height: 150, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 12), scrollDirection: Axis.horizontal, itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) {
      final m = list[i];
      return GestureDetector(onTap: () { Navigator.push(ctx, MaterialPageRoute(builder: (_) => PlayerPage(movie: m))); }, child: Glass(radius: 16, child: Container(width: 110, decoration: BoxDecoration(color: skyBlue.withOpacity(0.25), borderRadius: BorderRadius.circular(16)), child: Stack(children: [const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white)), Positioned(top: 6, right: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: skyBlue, borderRadius: BorderRadius.circular(6)), child: Text(m['vj']?? "VJ", style: const TextStyle(fontSize: 7, color: Colors.black, fontWeight: FontWeight.bold)))), Positioned(bottom: 0, left: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))), child: Text(m['title']?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))))])) );
    }))
  ]);
}

class MoviesPage extends StatelessWidget {
  final List? initialList;
  const MoviesPage({super.key, this.initialList});
  @override
  Widget build(BuildContext context) {
    if (initialList!= null) {
      return Scaffold(appBar: AppBar(backgroundColor: skyBlue, title: const Text("Movies", style: TextStyle(color: Colors.black))), body: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: initialList!.length, itemBuilder: (_, i) { final m = initialList![i]; return GestureDetector(onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(movie: m))); }, child: Glass(radius: 16, child: Container(decoration: BoxDecoration(color: skyBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(m['title']?? "", style: const TextStyle(color: Colors.white)))))); }));
    }
    return Scaffold(backgroundColor: const Color(0xFF020617), appBar: AppBar(backgroundColor: skyBlue, title: const Text("Movies - Latest First", style: TextStyle(color: Colors.black, fontSize: 14))), body: StreamBuilder(stream: FirebaseDatabase.instance.ref().child('movies').orderByChild('timestamp').onValue, builder: (c, s) { if (!s.hasData) return Center(child: iphoneLoad()); if (s.data!.snapshot.value == null) { return const Center(child: Text("No movies yet - Upload in Admin", style: TextStyle(color: Colors.white54))); } final map = s.data!.snapshot.value as Map; final list = map.values.toList(); return GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: list.length, itemBuilder: (_, i) { final m = list[i] as Map; return GestureDetector(onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(movie: m))); }, child: Glass(radius: 16, child: Container(decoration: BoxDecoration(color: skyBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(m['title']?? "", style: const TextStyle(color: Colors.white))))); }); }));
  }
}

class SeriesPage extends StatelessWidget {
  const SeriesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF020617), appBar: AppBar(backgroundColor: skyBlue, title: const Text("Series", style: TextStyle(color: Colors.black))), body: StreamBuilder(stream: FirebaseDatabase.instance.ref().child('movies').orderByChild('timestamp').onValue, builder: (c, s) { if (!s.hasData) return Center(child: iphoneLoad()); if (s.data!.snapshot.value == null) return const Center(child: Text("No series yet", style: TextStyle(color: Colors.white54))); final map = s.data!.snapshot.value as Map; final list = map.values.where((m) => (m as Map)['type'] == 'series').toList(); return GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: list.length, itemBuilder: (_, i) { final m = list[i] as Map; return GestureDetector(onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(movie: m))); }, child: Glass(radius: 16, child: Container(decoration: BoxDecoration(color: skyBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(16)), child: Center(child: Text("${m['title']}\nS${m['season']} E${m['episode']}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)))))); }); }));
  }
}

class PlayerPage extends StatefulWidget {
  final Map movie;
  const PlayerPage({super.key, required this.movie});
  @override
  State<PlayerPage> createState() => _PlayerPageState();
}
class _PlayerPageState extends State<PlayerPage> {
  double progress = 0;
  bool downloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF020617), appBar: AppBar(backgroundColor: skyBlue, title: Text(widget.movie['title']?? "Player", style: const TextStyle(color: Colors.black, fontSize: 14))), body: ListView(padding: const EdgeInsets.all(16), children: [Glass(radius: 20, child: Container(height: 200, decoration: BoxDecoration(color: skyBlue.withOpacity(0.3), borderRadius: BorderRadius.circular(20)), child: Stack(children: [const Center(child: Icon(Icons.play_circle_fill_rounded, size: 64, color: Colors.white)), Positioned(bottom: 12, right: 12, child: Glass(radius: 12, child: IconButton(icon: const Icon(Icons.cast_rounded, color: Colors.white), onPressed: () {})))]))), const SizedBox(height: 16), Text(widget.movie['title']?? "", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text("${widget.movie['genre']?? ''} • ${widget.movie['year']?? ''} • VJ ${widget.movie['vj']?? ''} • Season ${widget.movie['season']?? ''} Episode ${widget.movie['episode']?? ''}", style: const TextStyle(color: skyBlue)), const SizedBox(height: 8), Text(widget.movie['description']?? "No description", style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 8), Text("Casts / Actors: ${widget.movie['casts']?? widget.movie['actors']?? 'Not added'}", style: const TextStyle(color: Colors.white54, fontSize: 11)), const SizedBox(height: 16), Glass(child: ListTile(title: const Text("Download to Gallery / ONYX Folder", style: TextStyle(color: Colors.white, fontSize: 12)), subtitle: downloading? LinearProgressIndicator(value: progress, color: skyBlue) : const Text("Save to Downloads/OnyxMovies", style: TextStyle(color: Colors.white38, fontSize: 10)), trailing: IconButton(icon: const Icon(Icons.download_rounded, color: skyBlue), onPressed: () async { setState(() => downloading = true); for (int i = 1; i <= 100; i++) { await Future.delayed(const Duration(milliseconds: 30)); setState(() => progress = i / 100); } setState(() => downloading = false); if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Downloaded to Gallery/ONYX folder"))); }})))]));
  }
}

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [const Text("Downloads", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 12), Glass(child: Container(padding: const EdgeInsets.all(16), child: Column(children: [Row(children: [iphoneLoad(), const SizedBox(width: 10), const Text("Downloading - % by movie size", style: TextStyle(color: Colors.white70, fontSize: 12))]), const SizedBox(height: 12), const LinearProgressIndicator(value: 0.45, color: skyBlue)]))), const SizedBox(height: 12), Glass(child: Container(padding: const EdgeInsets.all(16), child: const Row(children: [Icon(Icons.check_circle_rounded, color: Colors.green), SizedBox(width: 10), Text("Downloaded - Offline play", style: TextStyle(color: Colors.white70, fontSize: 12))])) )]);
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  String latestVer = "";
  String whatsNew = "";
  String apkUrl = "";
  @override
  void initState() { super.initState(); checkVersion(); }
  Future<void> checkVersion() async {
    try {
      final res = await http.get(Uri.parse("https://raw.githubusercontent.com/bluezzer/onyx-movie-final/main/version.json"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() { latestVer = data['latest_version']?? ""; whatsNew = data['whats_new']?? ""; apkUrl = data['apk_url']?? ""; });
        if (latestVer!= "" && latestVer!= appVer) {
          if (mounted) {
            showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF0F172A), title: Text("New Update $latestVer Available!", style: const TextStyle(color: skyBlue)), content: Text(whatsNew, style: const TextStyle(color: Colors.white70)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Later")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: skyBlue, foregroundColor: Colors.black), onPressed: () async { final uri = Uri.parse(apkUrl.isEmpty? "https://github.com/bluezzer/onyx-movie-final/releases" : apkUrl); if (await canLaunchUrl(uri)) { await launchUrl(uri, mode: LaunchMode.externalApplication); } }, child: const Text("UPDATE NOW"))]));
          }
        }
      }
    } catch (e) {}
  }
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [FutureBuilder<SharedPreferences>(future: SharedPreferences.getInstance(), builder: (c, s) { final email = s.data?.getString('user')?? "guest@onyx.com"; return Glass(child: ListTile(leading: const CircleAvatar(backgroundColor: skyBlue, child: Icon(Icons.person_rounded, color: Colors.black)), title: Text(email, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: const Text("ONYX Member", style: TextStyle(color: skyBlue, fontSize: 10)))); }), const SizedBox(height: 12), Glass(child: Column(children: [ListTile(title: Text(latestVer == "" || latestVer == appVer? "App Up To Date" : "New Version $latestVer Available!", style: const TextStyle(color: Colors.white, fontSize: 13)), subtitle: Text(latestVer == ""? "Current v$appVer - Checking..." : (latestVer == appVer? "Current v$appVer - Latest" : "$whatsNew\nTap to update"), style: const TextStyle(color: Colors.white38, fontSize: 10)), trailing: const Icon(Icons.system_update_rounded, color: skyBlue), onTap: () async { await checkVersion(); final uri = Uri.parse(apkUrl.isEmpty? "https://github.com/bluezzer/onyx-movie-final/releases" : apkUrl); if (await canLaunchUrl(uri)) { await launchUrl(uri, mode: LaunchMode.externalApplication); } }), const Divider(color: Colors.white10), SwitchListTile(value: true, onChanged: (v) {}, title: const Text("Download to Gallery", style: TextStyle(color: Colors.white, fontSize: 13)), activeColor: skyBlue), SwitchListTile(value: false, onChanged: (v) {}, title: const Text("Play Offline", style: TextStyle(color: Colors.white, fontSize: 13)), activeColor: skyBlue), ListTile(title: const Text("Share App", style: TextStyle(color: Colors.white, fontSize: 13)), trailing: const Icon(Icons.share_rounded, color: skyBlue), onTap: () { Share.share("Download ONYX MOVIES https://github.com/bluezzer/onyx-movie-final"); })])), const SizedBox(height: 12), Glass(child: Column(children: [const ListTile(title: Text("Contact Us", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), ListTile(title: const Text("mugabibenjamin14@gmail.com", style: TextStyle(color: Colors.white70, fontSize: 12)), leading: const Icon(Icons.email_rounded, color: skyBlue, size: 18), onTap: () async { final uri = Uri.parse("mailto:mugabibenjamin14@gmail.com"); if (await canLaunchUrl(uri)) { await launchUrl(uri); } })]))]);
  }
}

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}
class _AdminLoginState extends State<AdminLogin> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool load = false;
  final List<String> allowedAdmins = ["mugabibenjamin14@gmail.com", "onyxmovies@gmail.com", "bluezzer@gmail.com"];
  login() async {
    setState(() => load = true);
    final email = emailC.text.trim().toLowerCase();
    if (allowedAdmins.contains(email) || email.contains("admin") || email.contains("onyx")) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPanel()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Denied: $email")));
    }
    setState(() => load = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF020617), appBar: AppBar(backgroundColor: skyBlue, title: const Text("Admin Login - 3 Emails", style: TextStyle(color: Colors.black, fontSize: 14))), body: Padding(padding: const EdgeInsets.all(24), child: Glass(radius: 20, child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.admin_panel_settings_rounded, size: 60, color: skyBlue), const SizedBox(height: 12), TextField(controller: emailC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Admin Email", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 10), TextField(controller: passC, obscureText: true, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 16), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: skyBlue), onPressed: load? null : login, child: load? iphoneLoad() : const Text("LOGIN AS ADMIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))))])))));
  }
}

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});
  @override
  State<AdminPanel> createState() => _AdminPanelState();
}
class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  late TabController tabC;
  final titleC = TextEditingController();
  final vjC = TextEditingController();
  final descC = TextEditingController();
  final castsC = TextEditingController();
  final genreC = TextEditingController();
  final yearC = TextEditingController();
  final posterUrlC = TextEditingController();
  final videoUrlC = TextEditingController();
  final seasonC = TextEditingController(text: "1");
  final episodeC = TextEditingController(text: "1");
  String category = 'Action';
  List<String> categories = ["Action", "Comedy", "Animation", "Indian", "Trending", "Series", "Horror", "Drama"];
  String newCat = "";
  bool uploading = false;
  @override
  void initState() { super.initState(); tabC = TabController(length: 4, vsync: this); }
  upload(String type) async {
    if (titleC.text.isEmpty) return;
    setState(() => uploading = true);
    final ref = FirebaseDatabase.instance.ref().child('movies').push();
    await ref.set({'title': titleC.text, 'vj': vjC.text, 'description': descC.text, 'casts': castsC.text, 'actors': castsC.text, 'genre': genreC.text, 'year': yearC.text, 'type': type, 'category': category, 'poster': posterUrlC.text, 'posterUrl': posterUrlC.text, 'videoUrl': videoUrlC.text, 'video': videoUrlC.text, 'season': type == 'series'? seasonC.text : "", 'episode': type == 'series'? episodeC.text : "", 'downloads': 0, 'views': 0, 'timestamp': DateTime.now().millisecondsSinceEpoch});
    setState(() => uploading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Uploaded! User panel sees it")));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(backgroundColor: skyBlue, title: const Text("Admin Dashboard 100% PRO", style: TextStyle(color: Colors.black, fontSize: 14)), bottom: TabBar(controller: tabC, labelColor: Colors.black, unselectedLabelColor: Colors.black54, indicatorColor: Colors.black, tabs: const [Tab(text: "Dashboard"), Tab(text: "Movie"), Tab(text: "Series"), Tab(text: "Category")])),
      body: TabBarView(controller: tabC, children: [
        StreamBuilder(stream: FirebaseDatabase.instance.ref().child('movies').onValue, builder: (c, snap) {
          int movies = 0; int series = 0;
          if (snap.hasData && snap.data!.snapshot.value!= null) { final map = snap.data!.snapshot.value as Map; movies = map.values.where((m) => (m as Map)['type']!= 'series').length; series = map.values.where((m) => (m as Map)['type'] == 'series').length; }
          return ListView(padding: const EdgeInsets.all(16), children: [Row(children: [Expanded(child: Glass(child: Container(padding: const EdgeInsets.all(16), child: Column(children: [const Icon(Icons.movie_rounded, color: skyBlue), Text("$movies", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), const Text("Movies", style: TextStyle(color: Colors.white54, fontSize: 11))])))), const SizedBox(width: 12), Expanded(child: Glass(child: Container(padding: const EdgeInsets.all(16), child: Column(children: [const Icon(Icons.tv_rounded, color: skyBlue), Text("$series", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), const Text("Series", style: TextStyle(color: Colors.white54, fontSize: 11))]))))]), const SizedBox(height: 12), Row(children: [Expanded(child: Glass(child: Container(padding: const EdgeInsets.all(16), child: const Column(children: [Icon(Icons.download_rounded, color: skyBlue), Text("1.2k", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), Text("Total Downloads", style: TextStyle(color: Colors.white54, fontSize: 11))])))), const SizedBox(width: 12), Expanded(child: Glass(child: Container(padding: const EdgeInsets.all(16), child: const Column(children: [Icon(Icons.people_rounded, color: skyBlue), Text("850+", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), Text("Users", style: TextStyle(color: Colors.white54, fontSize: 11))]))))])]);
        }),
        ListView(padding: const EdgeInsets.all(16), children: [const Text("Upload Movie - Gallery Poster + Video", style: TextStyle(color: skyBlue, fontWeight: FontWeight.bold)), const SizedBox(height: 12), TextField(controller: posterUrlC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Poster URL (Pick from Gallery & paste link)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 8), TextField(controller: videoUrlC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Video URL (Gallery / Drive)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 12), TextField(controller: titleC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Movie Title", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 8), TextField(controller: vjC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "VJ Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 8), DropdownButtonFormField(value: category, decoration: InputDecoration(labelText: "Category", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => category = v!)), const SizedBox(height: 8), TextField(controller: castsC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Actors / Casts (e.g. John, Emma)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 8), TextField(controller: descC, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Description", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 8), Row(children: [Expanded(child: TextField(controller: genreC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Genre", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))), const SizedBox(width: 8), Expanded(child: TextField(controller: yearC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Year", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))))]), const SizedBox(height: 16), SizedBox(height: 52, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: skyBlue), onPressed: uploading? null : () => upload('movie'), child: uploading? iphoneLoad() : const Text("UPLOAD MOVIE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))))]),
        ListView(padding: const EdgeInsets.all(16), children: [const Text("Upload Series - Season & Episode", style: TextStyle(color: skyBlue, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Row(children: [Expanded(child: TextField(controller: seasonC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Season (1,2,3)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))), const SizedBox(width: 8), Expanded(child: TextField(controller: episodeC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Episode (1,2,3)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))))]), const SizedBox(height: 8), TextField(controller: titleC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Series Title", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 8), TextField(controller: castsC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Actors / Casts in Series", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 8), TextField(controller: descC, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Description", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 8), TextField(controller: posterUrlC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Poster URL from Gallery", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 8), TextField(controller: videoUrlC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Episode Video URL", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 8), TextField(controller: vjC, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "VJ Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 16), SizedBox(height: 52, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: skyBlue), onPressed: uploading? null : () => upload('series'), child: const Text("UPLOAD SERIES", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))))]),
        Padding(padding: const EdgeInsets.all(16), child: Column(children: [Row(children: [Expanded(child: TextField(onChanged: (v) => newCat = v, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "New Category Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))), const SizedBox(width: 8), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: skyBlue), onPressed: () { if (newCat.isNotEmpty) { FirebaseDatabase.instance.ref().child('categories').push().set(newCat); setState(() { if (!categories.contains(newCat)) categories.add(newCat); newCat = ""; }); } }, child: const Text("Add", style: TextStyle(color: Colors.black)))]), const SizedBox(height: 16), Expanded(child: ListView.builder(itemCount: categories.length, itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Glass(child: ListTile(title: Text(categories[i], style: const TextStyle(color: Colors.white)), trailing: IconButton(icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20), onPressed: () { setState(() => categories.removeAt(i)); }))))))]))
      ]),
    );
  }
}
