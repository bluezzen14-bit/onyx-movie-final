import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'firebase_options.dart'; // <-- FIX 1: THIS WAS MISSING

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FIX 2: Proper Firebase init with error logging
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase Initialized: ${Firebase.apps.first.name}");
  } catch (e, stack) {
    print("❌ Firebase init FAILED: $e");
    print(stack);
    // Don't hide error, still run app but Splash will show real error
  }
  runApp(const OnyxApp());
}

class OnyxApp extends StatefulWidget {
  const OnyxApp({super.key});
  @override
  State<OnyxApp> createState() => OnyxAppState();
}

class OnyxAppState extends State<OnyxApp> {
  @override
  void initState() {
    super.initState();
    loadTheme();
  }
  loadTheme() async {
    // your existing theme loader
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Splash(),
    );
  }
  @override
  void dispose() { super.dispose(); }
}

class IPhoneLoader extends StatefulWidget {
  const IPhoneLoader({super.key});
  @override
  State<IPhoneLoader> createState() => _IPhoneLoaderState();
}
class _IPhoneLoaderState extends State<IPhoneLoader> with SingleTickerProviderStateMixin {
  late AnimationController ac;
  @override
  void initState() { super.initState(); ac = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(); }
  @override
  void dispose() { ac.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return const Center(child: CircularProgressIndicator(color: Colors.white)); }
}

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => SplashState();
}
class SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    check();
  }
  check() async {
    await Future.delayed(const Duration(seconds: 2));
    // FIX 3: Check Firebase actually initialized
    if (Firebase.apps.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Firebase not initialized! Check firebase_options.dart & google-services.json")),
        );
      }
      return;
    }
    final p = await SharedPreferences.getInstance();
    final email = p.getString('registered_email');
    final logged = p.getBool('is_logged_in')?? false;
    final hasPass = p.getString('app_passcode');
    if (!mounted) return;
    if (email!= null && logged) {
      if (hasPass!= null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PasscodeLock()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNav(email: email)));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Colors.black, body: Center(child: IPhoneLoader()));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => LoginScreenState();
}
class LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool load = false;
  void doLogin() async {
    if (emailC.text.trim().isEmpty || passC.text.trim().isEmpty) return;
    setState(() => load = true);
    final p = await SharedPreferences.getInstance();
    // your existing logic
    bool isAdmin = emailC.text.trim() == "mobijabin@gmail.com";
    await p.setString('registered_email', emailC.text.trim());
    await p.setBool('is_logged_in', true);
    await p.setBool('is_admin', isAdmin);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNav(email: emailC.text.trim())));
    }
    setState(() => load = false);
  }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    TextField(controller: emailC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Email")),
    TextField(controller: passC, obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Password")),
    const SizedBox(height: 20),
    load? const IPhoneLoader() : ElevatedButton(onPressed: doLogin, child: const Text("Login"))
  ])));
}

class PasscodeLock extends StatefulWidget {
  const PasscodeLock({super.key});
  @override
  State<PasscodeLock> createState() => _PasscodeLockState();
}
class _PasscodeLockState extends State<PasscodeLock> {
  String entered = "";
  final LocalAuthentication auth = LocalAuthentication();
  @override
  void initState() { super.initState(); tryBio(); }
  tryBio() async {
    final p = await SharedPreferences.getInstance();
    final useBio = p.getBool('use_biometric')?? false;
    if (useBio) {
      try {
        bool didAuth = await auth.authenticate(localizedReason: 'Unlock ONYX');
        if (didAuth && mounted) {
          final email = p.getString('registered_email')?? "";
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNav(email: email)));
        }
      } catch (_) {}
    }
  }
  onNum(String n) async {
    if (entered.length >= 6) return;
    setState(() => entered += n);
    if (entered.length == 6) {
      final p = await SharedPreferences.getInstance();
      final saved = p.getString('app_passcode');
      if (entered == saved) {
        if (mounted) {
          final email = p.getString('registered_email')?? "";
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNav(email: email)));
        }
      } else {
        setState(() => entered = "");
      }
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, body: Center(child: Text("Enter Passcode: $entered", style: const TextStyle(color: Colors.white))));
}

// --- MAIN NAV ---
class MainNav extends StatefulWidget {
  final String email;
  const MainNav({super.key, required this.email});
  @override
  State<MainNav> createState() => MainNavState();
}
class MainNavState extends State<MainNav> {
  int idx = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [HomeFull(email: widget.email), const MoviesFullPage(), const SeriesFullPage(), const DownloadFullPage(), ProfileFull(email: widget.email)];
    return Scaffold(
      backgroundColor: Colors.black,
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (v) => setState(() => idx = v),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movies"),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Series"),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: "Downloads"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class SafePoster extends StatelessWidget {
  final String base64Str;
  final double? width;
  final double? height;
  const SafePoster({super.key, required this.base64Str, this.width, this.height});
  @override
  Widget build(BuildContext context) {
    Widget img;
    if (base64Str.isEmpty) {
      img = Container(color: Colors.grey[900], child: const Icon(Icons.movie, color: Colors.white30));
    } else {
      try {
        final bytes = base64Decode(base64Str);
        img = Image.memory(bytes, fit: BoxFit.cover, width: width, height: height);
      } catch (_) {
        img = Image.network(base64Str, fit: BoxFit.cover, width: width, height: height, errorBuilder: (_,__,___) => Container(color: Colors.grey[900]));
      }
    }
    return ClipRRect(borderRadius: BorderRadius.circular(12), child: img);
  }
}

class LiquidSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const LiquidSearchBar({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
          child: Row(children: const [Icon(Icons.search, color: Colors.white70), SizedBox(width: 10), Text("Search movies, series...", style: TextStyle(color: Colors.white70))]),
        ),
      ),
    );
  }
}

// --- HOME FULL - FIXED ---
class HomeFull extends StatefulWidget {
  final String email;
  const HomeFull({super.key, required this.email});
  @override
  State<HomeFull> createState() => HomeFullState();
}
class HomeFullState extends State<HomeFull> {
  DatabaseReference? refY;
  DatabaseReference? refYGenres;
  List<String> vList = ["All"];
  String selV = "All";
  String selGen = "All";
  List<String> favIds = [];

  @override
  void initState() {
    super.initState();
    // FIX: Initialize refs with error handling
    try {
      refY = FirebaseDatabase.instance.ref('movies');
      refYGenres = FirebaseDatabase.instance.ref('genres');
    } catch (e) {
      print("DB Ref error: $e");
    }
    loadVJ();
    loadCats();
    loadFav();
    checkUpdate();
  }

  // FIX: New function to show REAL error, not fake "not configured"
  Widget buildError(Object error) {
    String msg = error.toString();
    if (msg.contains("permission-denied") || msg.contains("PERMISSION_DENIED")) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Icon(Icons.lock, size: 60, color: Colors.red),
          const SizedBox(height: 10),
          const Text("Database Permission Denied!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Go to Firebase Console > Realtime Database > Rules > set.read/.write = true", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(msg, style: const TextStyle(color: Colors.white30, fontSize: 10)),
        ]),
      );
    }
    if (msg.contains("not-found") || msg.contains("No data")) {
      return const Center(child: Text("No movies yet. Add from Admin Panel", style: TextStyle(color: Colors.white70)));
    }
    // Real Firebase not configured
    if (Firebase.apps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Column(children: [
          Icon(Icons.warning, size: 60, color: Colors.orange),
          SizedBox(height: 10),
          Text("Firebase not configured!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("1. Check lib/firebase_options.dart exists\n2. Check android/app/google-services.json exists\n3. Run flutterfire configure", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
        ]),
      );
    }
    return Center(child: Text("Error: $msg", style: const TextStyle(color: Colors.white70)));
  }

  checkUpdate() async {
    try {
      final snap = await FirebaseDatabase.instance.ref('app_settings').get();
      if (snap.value == null) return;
      final data = Map<String, dynamic>.from(snap.value as Map);
      final latest = data['latestVersion']?? "1.1.2";
      const current = "1.1.2";
      if (latest!= current && mounted) {
        showDialog(context: context, builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1F2939),
          title: Text("Update Available: $latest"),
          content: Text("Current: $current\n${data['whatsNew']?? ''}"),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Later"))],
        ));
      }
    } catch (e) { print("Update check failed: $e"); }
  }

  loadVJ() async {
    final p = await SharedPreferences.getInstance();
    // your VJ loading
  }
  loadCats() async {
    try {
      final s = await refYGenres?.get();
      // parse genres
    } catch (_) {}
  }
  loadFav() async {
    final p = await SharedPreferences.getInstance();
    favIds = p.getStringList('fav_ids')?? [];
    setState(() {});
  }
  toggleFav(String id) async {
    final p = await SharedPreferences.getInstance();
    if (favIds.contains(id)) { favIds.remove(id); } else { favIds.add(id); }
    await p.setStringList('fav_ids', favIds);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (refY == null) {
      return Scaffold(backgroundColor: Colors.black, body: Center(child: buildError("Firebase not initialized")));
    }
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: LiquidSearchBar(onTap: () {})),
          // FIX: StreamBuilder with proper error handling
          SliverToBoxAdapter(
            child: StreamBuilder(
              stream: refY!.onValue,
              builder: (context, snap) {
                if (snap.hasError) {
                  return buildError(snap.error!);
                }
                if (!snap.hasData || snap.data!.snapshot.value == null) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Column(children: [
                      Icon(Icons.movie_filter, size: 50, color: Colors.white30),
                      SizedBox(height: 10),
                      Text("No movies in database", style: TextStyle(color: Colors.white70)),
                      Text("Go to Profile > Admin Panel > Add Movie", style: TextStyle(color: Colors.white30, fontSize: 12)),
                    ])),
                  );
                }
                final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
                var all = map.entries.toList();
                var movies = all.where((e) => true).toList(); // your filter logic
                var trending = movies.take(10).toList();
                return Column(children: [
                  section('Latest Release', movies),
                  section('Trending Movies', trending),
                ]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget section(String title, List<MapEntry> items) {
    if (items.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (_, i) {
              final m = Map<String, dynamic>.from(items[i].value);
              final isFav = favIds.contains(items[i].key);
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(movie: m))),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.all(6),
                  child: Column(children: [
                    Expanded(child: SafePoster(base64Str: m['poster']?? "", width: 120)),
                    Text(m['title']?? "", style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              );
            },
          ),
        )
      ]),
    );
  }
}

// --- KEEP YOUR OTHER CLASSES AS THEY WERE, JUST COPY BELOW ---
// For brevity I will keep stubs, replace with your original classes from video

class FilterPage extends StatelessWidget { const FilterPage({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class SeeMorePage extends StatelessWidget { const SeeMorePage({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class MoviesFullPage extends StatelessWidget {
  const MoviesFullPage({super.key});
  @override Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('movies');
    return SafeArea(child: StreamBuilder(
      stream: ref.onValue,
      builder: (c, snap) {
        if (snap.hasError) return Center(child: Text("DB Error: ${snap.error}\nCheck Rules = true", style: TextStyle(color: Colors.white)));
        if (!snap.hasData || snap.data!.snapshot.value == null) return Center(child: Text("No movies", style: TextStyle(color: Colors.white70)));
        return const Center(child: Text("Movies Loaded ✅", style: TextStyle(color: Colors.green)));
      },
    ));
  }
}
class SeriesFullPage extends StatelessWidget {
  const SeriesFullPage({super.key});
  @override Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('series');
    return SafeArea(child: StreamBuilder(
      stream: ref.onValue,
      builder: (c, snap) {
        if (snap.hasError) return Center(child: Text("DB Error: ${snap.error}", style: TextStyle(color: Colors.white)));
        if (!snap.hasData || snap.data!.snapshot.value == null) return const Center(child: Text("No series", style: TextStyle(color: Colors.white70)));
        return const Center(child: Text("Series Loaded ✅", style: TextStyle(color: Colors.green)));
      },
    ));
  }
}
class PlayerPage extends StatelessWidget {
  final Map movie;
  const PlayerPage({super.key, required this.movie});
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, appBar: AppBar(title: Text(movie['title']?? "")), body: Center(child: Text(movie['description']?? "", style: TextStyle(color: Colors.white))));
}
class DownloadFullPage extends StatefulWidget { const DownloadFullPage({super.key}); @override State<DownloadFullPage> createState() => _DownloadFullPageState(); }
class _DownloadFullPageState extends State<DownloadFullPage> {
  List<String> downloaded = [];
  @override void initState() { super.initState(); load(); }
  load() async { final p = await SharedPreferences.getInstance(); downloaded = p.getStringList('downloaded_movies')?? []; setState(() {}); }
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, body: Center(child: Text("Downloads: ${downloaded.length}", style: TextStyle(color: Colors.white))));
}
class ProfileFull extends StatefulWidget {
  final String email;
  const ProfileFull({super.key, required this.email});
  @override State<ProfileFull> createState() => ProfileFullState();
}
class ProfileFullState extends State<ProfileFull> {
  bool dark = true;
  @override Widget build(BuildContext context) {
    bool isAdmin = widget.email == "mobijabin@gmail.com";
    return Scaffold(backgroundColor: Colors.black, body: ListView(children: [
      ListTile(title: Text(widget.email, style: TextStyle(color: Colors.white)), subtitle: Text(isAdmin? "Admin" : "User", style: TextStyle(color: Colors.white70))),
      if (isAdmin) ListTile(leading: Icon(Icons.admin_panel_settings, color: Colors.white), title: Text("Admin Panel", style: TextStyle(color: Colors.white)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPanelFull(email: widget.email)))),
    ]));
  }
}
class AdminPanelFull extends StatefulWidget {
  final String email;
  const AdminPanelFull({super.key, required this.email});
  @override State<AdminPanelFull> createState() => _AdminPanelFullState();
}
class _AdminPanelFullState extends State<AdminPanelFull> {
  int idx = 0;
  @override Widget build(BuildContext context) {
    final pages = [AdminDashFull(email: widget.email), const AdminMovieFull(), const AdminSeriesFull(), const AdminSettingsFull()];
    return Scaffold(backgroundColor: Colors.black, body: pages[idx], bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap: (v) => setState(() => idx = v), items: const [BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dash"), BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movie"), BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Series"), BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")]));
  }
}
class AdminDashFull extends StatelessWidget {
  final String email;
  const AdminDashFull({super.key, required this.email});
  @override Widget build(BuildContext context) => Center(child: Text("Welcome Admin ${email}", style: TextStyle(color: Colors.white)));
}
class AdminMovieFull extends StatefulWidget { const AdminMovieFull({super.key}); @override State<AdminMovieFull> createState() => AdminMovieFullState(); }
class AdminMovieFullState extends State<AdminMovieFull> {
  final titleC = TextEditingController();
  String genre = "Action";
  Future upload() async {
    if (titleC.text.isEmpty) return;
    final ref = FirebaseDatabase.instance.ref('movies').push();
    await ref.set({"title": titleC.text, "genre": genre, "poster": "", "createdAt": DateTime.now().toString()});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Movie Added ✅")));
  }
  @override Widget build(BuildContext context) => Padding(padding: EdgeInsets.all(16), child: Column(children: [TextField(controller: titleC, decoration: InputDecoration(labelText: "Title")), SizedBox(height: 10), ElevatedButton(onPressed: upload, child: Text("Add Movie"))]));
}
class AdminSeriesFull extends StatefulWidget { const AdminSeriesFull({super.key}); @override State<AdminSeriesFull> createState() => AdminSeriesFullState(); }
class AdminSeriesFullState extends State<AdminSeriesFull> {
  final titleC = TextEditingController();
  Future upload() async {
    final ref = FirebaseDatabase.instance.ref('series').push();
    await ref.set({"title": titleC.text, "createdAt": DateTime.now().toString()});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Series Added ✅")));
  }
  @override Widget build(BuildContext context) => Padding(padding: EdgeInsets.all(16), child: Column(children: [TextField(controller: titleC, decoration: InputDecoration(labelText: "Series Title")), ElevatedButton(onPressed: upload, child: Text("Add Series"))]));
}
class AdminSettingsFull extends StatefulWidget { const AdminSettingsFull({super.key}); @override State<AdminSettingsFull> createState() => AdminSettingsFullState(); }
class AdminSettingsFullState extends State<AdminSettingsFull> {
  final verC = TextEditingController();
  final whatC = TextEditingController();
  save() async {
    await FirebaseDatabase.instance.ref('app_settings').set({"latestVersion": verC.text, "whatsNew": whatC.text});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved ✅")));
  }
  @override Widget build(BuildContext context) => Padding(padding: EdgeInsets.all(16), child: Column(children: [TextField(controller: verC, decoration: InputDecoration(labelText: "Latest Version e.g 1.1.2")), TextField(controller: whatC, decoration: InputDecoration(labelText: "Whats New")), ElevatedButton(onPressed: save, child: Text("Save"))]));
}
