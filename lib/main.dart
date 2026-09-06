import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAqhqupsd2veboIOFZfIjaNNOKpKxlV2MI",
      authDomain: "onyx-movies-2b58b.firebaseapp.com",
      databaseURL: "https://onyx-movies-2b58b-default-rtdb.firebaseio.com",
      projectId: "onyx-movies-2b58b",
      storageBucket: "onyx-movies-2b58b.firebasestorage.app",
      messagingSenderId: "243702982500",
      appId: "1:243702982500:web:a65b9c59dd2e06c3ec7c71",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode mode = ThemeMode.dark;
  @override
  void initState() {
    super.initState();
    loadTheme();
  }
  loadTheme() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      mode = (p.getBool('isDark')?? true)? ThemeMode.dark : ThemeMode.light;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF020617),
      ),
      home: MainNav(
        onTheme: (isDark) async {
          final p = await SharedPreferences.getInstance();
          await p.setBool('isDark', isDark);
          setState(() {
            mode = isDark? ThemeMode.dark : ThemeMode.light;
          });
        },
      ),
    );
  }
}

class MainNav extends StatefulWidget {
  final Function(bool) onTheme;
  const MainNav({super.key, required this.onTheme});
  @override
  State<MainNav> createState() => MainNavState();
}

class MainNavState extends State<MainNav> {
  int idx = 0;
  late List<Widget> pages;
  @override
  void initState() {
    super.initState();
    pages = [
      HomeTab(),
      MoviesTab(),
      SeriesTab(),
      DownloadsTab(),
      ProfileTab(onTheme: widget.onTheme),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF0F172A),
        selectedItemColor: Color(0xFF38BDF8),
        unselectedItemColor: Colors.white54,
        onTap: (i) => setState(() => idx = i),
        items: [
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

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  final ref = FirebaseDatabase.instance.ref('movies');
  String q = "";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => q = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search Movies / Series...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: ref.onValue,
              builder: (c, snap) {
                if (!snap.hasData || snap.data!.snapshot.value == null) {
                  return Center(child: CircularProgressIndicator());
                }
                final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
                final list = map.entries.where((e) {
                  final m = Map<String, dynamic>.from(e.value as Map);
                  return (m['title']?? '').toString().toLowerCase().contains(q);
                }).toList();
                if (list.isEmpty) {
                  return Center(child: Text("No Movies Found", style: TextStyle(color: Colors.white54)));
                }
                return GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: list.length,
                  itemBuilder: (c, i) {
                    final m = Map<String, dynamic>.from(list[i].value as Map);
                    return MovieCard(data: m, id: list[i].key);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MoviesTab extends StatefulWidget {
  const MoviesTab({super.key});
  @override
  State<MoviesTab> createState() => MoviesTabState();
}

class MoviesTabState extends State<MoviesTab> {
  final ref = FirebaseDatabase.instance.ref('movies');
  String q = "";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => q = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search Movies...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.movie, color: Color(0xFF38BDF8)),
                SizedBox(width: 8),
                Text("Movies", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: StreamBuilder(
              stream: ref.onValue,
              builder: (c, snap) {
                if (!snap.hasData || snap.data!.snapshot.value == null) {
                  return Center(child: Text("No Movies", style: TextStyle(color: Colors.white54)));
                }
                final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
                final list = map.entries.where((e) {
                  final m = Map<String, dynamic>.from(e.value as Map);
                  final cat = (m['category']?? 'Movie').toString().toLowerCase();
                  final isMovie = cat.contains('movie') ||!cat.contains('series');
                  final title = (m['title']?? '').toString().toLowerCase();
                  return isMovie && title.contains(q);
                }).toList();
                return GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: list.length,
                  itemBuilder: (c, i) {
                    final m = Map<String, dynamic>.from(list[i].value as Map);
                    return MovieCard(data: m, id: list[i].key);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SeriesTab extends StatefulWidget {
  const SeriesTab({super.key});
  @override
  State<SeriesTab> createState() => SeriesTabState();
}

class SeriesTabState extends State<SeriesTab> {
  final ref = FirebaseDatabase.instance.ref('movies');
  String q = "";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => q = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search Series...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.tv, color: Color(0xFF38BDF8)),
                SizedBox(width: 8),
                Text("Series", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: StreamBuilder(
              stream: ref.onValue,
              builder: (c, snap) {
                if (!snap.hasData || snap.data!.snapshot.value == null) {
                  return Center(child: Text("No Series", style: TextStyle(color: Colors.white54)));
                }
                final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
                final list = map.entries.where((e) {
                  final m = Map<String, dynamic>.from(e.value as Map);
                  final cat = (m['category']?? '').toString().toLowerCase();
                  return cat.contains('series') && (m['title']?? '').toString().toLowerCase().contains(q);
                }).toList();
                if (list.isEmpty) {
                  return Center(child: Text("No Series Found", style: TextStyle(color: Colors.white54)));
                }
                return GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 8,
     class MovieCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String id;
  const MovieCard({super.key, required this.data, required this.id});
  @override
  Widget build(BuildContext context) {
    final poster = data['posterBase64']?? '';
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(data: data, id: id)));
      },
      child: Container(
        decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: poster.toString().length > 100
                   ? Image.memory(base64Decode(poster.toString().split(',').last), fit: BoxFit.cover, width: double.infinity)
                    : Center(child: Icon(Icons.movie, size: 40)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(6),
              child: Text(data['title']?? 'No Title', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 6, bottom: 6),
              child: Text("${data['vj']?? 'VJ Junior'} • ${data['genre']?? 'Action'}", style: TextStyle(color: Colors.white54, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String id;
  const DetailPage({super.key, required this.data, required this.id});
  @override
  Widget build(BuildContext context) {
    final casts = data['casts'] is List? data['casts'] as List : [];
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFF020617), title: Text(data['title']?? '')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(aspectRatio: 16/9, child: Container(color: Color(0xFF1E293B), child: Icon(Icons.play_circle, size: 60))),
            ),
            SizedBox(height: 12),
            Text(data['title']?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text("${data['vj']?? ''} | ${data['genre']?? ''} • ${data['category']?? 'Movie'}", style: TextStyle(color: Colors.white54)),
            SizedBox(height: 12),
            Text("Casts - 5 circle + Real + Acted", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            casts.isEmpty
               ? Text("No casts added", style: TextStyle(color: Colors.white54))
                : SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: casts.length > 5? 5 : casts.length,
                      itemBuilder: (c, i) {
                        final cast = Map<String, dynamic>.from(casts[i] as Map);
                        final img = cast['imageBase64']?? '';
                        return Container(
                          width: 80,
                          margin: EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0xFF1E293B),
                                backgroundImage: img.toString().length > 100? MemoryImage(base64Decode(img.toString().split(',').last)) : null,
                                child: img.toString().length < 100? Icon(Icons.person) : null,
                              ),
                              SizedBox(height: 4),
                              Text(cast['realName']?? '', maxLines: 1, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              Text("as ${cast['actedName']?? ''}", maxLines: 1, style: TextStyle(fontSize: 9, color: Colors.white54)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 12),
            Text(data['description']?? 'No description', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class DownloadsTab extends StatefulWidget {
  const DownloadsTab({super.key});
  @override
  State<DownloadsTab> createState() => DownloadsTabState();
}

class DownloadsTabState extends State<DownloadsTab> with SingleTickerProviderStateMixin {
  late TabController tab;
  @override
  void initState() {
    super.initState();
    tab = TabController(length: 2, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.storage, color: Color(0xFF38BDF8)),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Used: 3.2GB / 15.7GB", style: TextStyle(color: Colors.white, fontSize: 12)),
                      SizedBox(height: 4),
                      LinearProgressIndicator(value: 0.2, backgroundColor: Colors.white12, color: Color(0xFF38BDF8)),
                      SizedBox(height: 4),
                      Text("Free: 12.5GB available", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TabBar(controller: tab, labelColor: Color(0xFF38BDF8), tabs: [Tab(text: "Downloading"), Tab(text: "Completed")]),
          Expanded(
            child: TabBarView(
              controller: tab,
              children: [
                Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.downloading, size: 80, color: Colors.white24), SizedBox(height: 10), Text("No active downloads", style: TextStyle(color: Colors.white54))])),
                Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.download_done, size: 80, color: Colors.white24), SizedBox(height: 10), Text("No available download", style: TextStyle(color: Colors.white54))])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}               mainAxisSpacing: 8,
                  ),
                  itemCount: list.length,
                  itemBuilder: (c, i) {
                    final m = Map<String, dynamic>.from(list[i].value as Map);
                    return MovieCard(data: m, id: list[i].key);
                  },
                );
              },
            ),
          ),
        ],
      ),class ProfileTab extends StatefulWidget {
  final Function(bool) onTheme;
  const ProfileTab({super.key, required this.onTheme});
  @override
  State<ProfileTab> createState() => ProfileTabState();
}

class ProfileTabState extends State<ProfileTab> {
  bool isDark = true;
  bool galleryMode = true;
  final picker = ImagePicker();
  Uint8List? avatarBytes;
  Future<void> pickAvatar() async {
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x!= null) {
      final b = await x.readAsBytes();
      setState(() => avatarBytes = b);
      final p = await SharedPreferences.getInstance();
      await p.setString('avatar', base64Encode(b));
    }
  }
  @override
  void initState() {
    super.initState();
    loadData();
  }
  loadData() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      isDark = p.getBool('isDark')?? true;
      galleryMode = p.getBool('galleryMode')?? true;
    });
    final av = p.getString('avatar');
    if (av!= null) setState(() => avatarBytes = base64Decode(av));
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(12),
        children: [
          Center(child: GestureDetector(onTap: pickAvatar, child: CircleAvatar(radius: 45, backgroundColor: Color(0xFF1E293B), backgroundImage: avatarBytes!= null? MemoryImage(avatarBytes!) : null, child: avatarBytes == null? Icon(Icons.person, size: 40) : null))),
          SizedBox(height: 10),
          Center(child: Text("Tap to change avatar from Gallery", style: TextStyle(color: Colors.white54, fontSize: 12))),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(color: Color(0xFF38BDF8), borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.add_box, color: Colors.black),
              title: Text("ADMIN: Add New Movie", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              subtitle: Text("Gallery poster/banner + 5 casts", style: TextStyle(color: Colors.black54, fontSize: 11)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAddMovie())),
            ),
          ),
          SizedBox(height: 12),
          ListTile(title: Text("Theme Dark"), trailing: Switch(value: isDark, onChanged: (v) async { setState(() => isDark = v); widget.onTheme(v); final p = await SharedPreferences.getInstance(); await p.setBool('isDark', v); })),
          ListTile(title: Text("Gallery Mode Switch"), trailing: Switch(value: galleryMode, onChanged: (v) async { setState(() => galleryMode = v); final p = await SharedPreferences.getInstance(); await p.setBool('galleryMode', v); })),
          Divider(color: Colors.white12),
          ListTile(leading: Icon(Icons.download, color: Color(0xFF38BDF8)), title: Text("Download Latest & Install"), subtitle: Text("Get V1.1.0 APK", style: TextStyle(fontSize: 12, color: Colors.white54)), onTap: () async { final uri = Uri.parse("https://github.com/bluezzer/onyx-movie-final/releases"); if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }),
          ListTile(leading: Icon(Icons.security, color: Color(0xFF38BDF8)), title: Text("Security - Biometric"), onTap: () async { final auth = LocalAuthentication(); final can = await auth.canCheckBiometrics; if (can) { final did = await auth.authenticate(localizedReason: "Authenticate"); if (did && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Authenticated"))); } }),
          ListTile(leading: Icon(Icons.contact_mail, color: Color(0xFF38BDF8)), title: Text("Contact Us"), onTap: () async { final uri = Uri.parse("mailto:support@onyxmovies.com"); if (await canLaunchUrl(uri)) await launchUrl(uri); }),
          ListTile(leading: Icon(Icons.app_registration, color: Color(0xFF38BDF8)), title: Text("Register"), onTap: () { showDialog(context: context, builder: (_) => AlertDialog(title: Text("Register"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: InputDecoration(labelText: "Email")), TextField(decoration: InputDecoration(labelText: "Password"), obscureText: true)]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Sign Up"))])); }),
        ],
      ),
    );
  }
}

class AdminAddMovie extends StatefulWidget {
  const AdminAddMovie({super.key});
  @override
  State<AdminAddMovie> createState() => AdminAddMovieState();
}

class AdminAddMovieState extends State<AdminAddMovie> {
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final vjC = TextEditingController(text: "VJ Junior");
  final genreC = TextEditingController(text: "Action");
  String category = "Movie";
  final picker = ImagePicker();
  Uint8List? posterBytes;
  Uint8List? bannerBytes;
  List<Map<String, dynamic>> casts = [];
  pickPoster() async {
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x!= null) { final b = await x.readAsBytes(); setState(() => posterBytes = b); }
  }
  pickBanner() async {
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x!= null) { final b = await x.readAsBytes(); setState(() => bannerBytes = b); }
  }
  addCast() async {
    if (casts.length >= 5) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Max 5 casts"))); return; }
    final realC = TextEditingController();
    final actedC = TextEditingController();
    Uint8List? castImg;
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (c, setS) => AlertDialog(
          title: Text("Add Cast"),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(onTap: () async { final x = await picker.pickImage(source: ImageSource.gallery); if (x!= null) { final b = await x.readAsBytes(); setS(() => castImg = b); } }, child: CircleAvatar(radius: 30, backgroundImage: castImg!= null? MemoryImage(castImg!) : null, child: castImg == null? Icon(Icons.person) : null)),
            TextField(controller: realC, decoration: InputDecoration(labelText: "Real Name")),
            TextField(controller: actedC, decoration: InputDecoration(labelText: "Acted Name")),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(onPressed: () { setState(() { casts.add({"realName": realC.text, "actedName": actedC.text, "imageBase64": castImg!= null? base64Encode(castImg!) : ""}); }); Navigator.pop(context); }, child: Text("Add")),
          ],
        ),
      ),
    );
  }
  save() async {
    if (titleC.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Title required"))); return; }
    final ref = FirebaseDatabase.instance.ref('movies').push();
    await ref.set({
      "title": titleC.text,
      "description": descC.text,
      "vj": vjC.text,
      "genre": genreC.text,
      "category": category,
      "posterBase64": posterBytes!= null? base64Encode(posterBytes!) : "",
      "bannerBase64": bannerBytes!= null? base64Encode(bannerBytes!) : "",
      "casts": casts,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });
    if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added to $category"))); Navigator.pop(context); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ADMIN: Add Movie")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: titleC, decoration: InputDecoration(labelText: "Movie Title *")),
            TextField(controller: descC, decoration: InputDecoration(labelText: "Description")),
            TextField(controller: vjC, decoration: InputDecoration(labelText: "VJ Name")),
            TextField(controller: genreC, decoration: InputDecoration(labelText: "Genre")),
            SizedBox(height: 12),
            Row(children: [Text("Category:"), SizedBox(width: 10), DropdownButton<String>(value: category, items: ["Movie", "Series"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => category = v!))]),
            SizedBox(height: 12),
            Row(children: [Expanded(child: ElevatedButton.icon(onPressed: pickPoster, icon: Icon(Icons.image), label: Text(posterBytes == null? "Pick Poster" : "Poster OK"))), SizedBox(width: 8), Expanded(child: ElevatedButton.icon(onPressed: pickBanner, icon: Icon(Icons.panorama), label: Text(bannerBytes == null? "Pick Banner" : "Banner OK")))]),
            SizedBox(height: 12),
            Row(children: [Text("Casts (max 5)"), Spacer(), ElevatedButton(onPressed: addCast, child: Text("Add Cast"))]),
            SizedBox(height: 8),
            Wrap(spacing: 8, children: casts.map((c) => Chip(label: Text(c['realName']))).toList()),
            SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: save, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF38BDF8)), child: Text("Save to Firebase", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
          ],
        ),
      ),
    );
  }
}
    );
  }
}
