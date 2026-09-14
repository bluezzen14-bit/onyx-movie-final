import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'firebase_options.dart';

const Color kBlue = Color(0xFF007AFF);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
  }
  runApp(const OnyxApp());
}

class OnyxApp extends StatefulWidget {
  const OnyxApp({super.key});
  @override
  State<OnyxApp> createState() => OnyxAppState();
}

class OnyxAppState extends State<OnyxApp> {
  bool dark = true;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  loadTheme() async {
    final p = await SharedPreferences.getInstance();
    setState(() => dark = p.getBool('dark_mode')?? true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(onTheme: () {
        loadTheme();
      }),
    );
  }
}

class IPhoneLoader extends StatefulWidget {
  final double size;
  const IPhoneLoader({super.key, this.size = 32});
  @override
  State<IPhoneLoader> createState() => IPhoneLoaderState();
}

class IPhoneLoaderState extends State<IPhoneLoader> with SingleTickerProviderStateMixin {
  late AnimationController ac;

  @override
  void initState() {
    super.initState();
    ac = AnimationController(vsync: this, duration: Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: ac,
      child: Icon(Icons.autorenew, size: widget.size, color: Colors.white.withOpacity(0.75)),
    );
  }
}

class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  const LiquidGlass({super.key, required this.child, this.radius = 20, this.padding});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

class Splash extends StatefulWidget {
  final VoidCallback onTheme;
  const Splash({super.key, required this.onTheme});
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
    await Future.delayed(Duration(seconds: 2));
    final p = await SharedPreferences.getInstance();
    final email = p.getString('registered_email_permanent');
    final logged = p.getBool('is_logged_in')?? false;
    final hasPass = p.getString('app_passcode');
    if (mounted) {
      if (email!= null && logged) {
        if (hasPass!= null) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PasscodeLock(email: email, isAdmin: p.getBool('is_admin')?? false, onTheme: widget.onTheme)));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNav(email: email, isAdmin: p.getBool('is_admin')?? false, onTheme: widget.onTheme)));
        }
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen(onTheme: widget.onTheme)));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.movie_filter, size: 80, color: kBlue),
              SizedBox(height: 10),
              Text('ONYX MOVIES', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              IPhoneLoader(size: 38)
            ],
          ),
        ),
      );
}

class LoginScreen extends StatefulWidget {
  final VoidCallback onTheme;
  const LoginScreen({super.key, required this.onTheme});
  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  String err = '';
  bool load = false;
  final _auth = FirebaseAuth.instance;

  Future<void> signInGoogle() async {
    setState(() => load = true);
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) {
        setState(() => load = false);
        return;
      }
      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final cred = GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken);
      final userCred = await _auth.signInWithCredential(cred);
      final email = userCred.user?.email?.toLowerCase()?? gUser.email.toLowerCase();
      final p = await SharedPreferences.getInstance();
      await p.setString('registered_email_permanent', email);
      await p.setBool('is_logged_in', true);
      await p.setBool('is_admin', email == 'mugabibenjamin14@gmail.com');
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNav(email: email, isAdmin: email == 'mugabibenjamin14@gmail.com', onTheme: widget.onTheme)));
    } catch (e) {
      setState(() => err = 'Google Error: $e');
    }
    setState(() => load = false);
  }

  void doLogin() async {
    if (emailC.text.trim().isEmpty || passC.text.isEmpty) {
      setState(() => err = 'Enter email and password');
      return;
    }
    setState(() => load = true);
    final p = await SharedPreferences.getInstance();
    final email = emailC.text.trim().toLowerCase();
    bool isAdmin = email == 'mugabibenjamin14@gmail.com' && passC.text == 'Mugabibe+-@1';
    await p.setString('registered_email_permanent', email);
    await p.setBool('is_logged_in', true);
    await p.setBool('is_admin', isAdmin);
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNav(email: email, isAdmin: isAdmin, onTheme: widget.onTheme)));
    setState(() => load = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie_filter, size: 70, color: kBlue),
                SizedBox(height: 10),
                Text('ONYX MOVIES', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kBlue)),
                SizedBox(height: 30),
                LiquidGlass(
                  radius: 16,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailC,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: passC,
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                if (err.isNotEmpty) Text(err, style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: load? null : doLogin,
                    style: ElevatedButton.styleFrom(backgroundColor: kBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: load? IPhoneLoader() : Text('LOGIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: load? null : signInGoogle,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    icon: Icon(Icons.g_mobiledata, size: 30, color: Colors.black),
                    label: Text('Sign in with Google', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(onTheme: widget.onTheme)));
                  },
                  child: Text('No account? Register', style: TextStyle(color: kBlue)),
                )
              ],
            ),
          ),
        ),
      );
}

class RegisterScreen extends StatefulWidget {
  final VoidCallback onTheme;
  const RegisterScreen({super.key, required this.onTheme});
  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();
  String err = '';
  bool load = false;

  Future<void> signUp() async {
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      setState(() => err = 'Fill all fields');
      return;
    }
    if (passC.text!= confirmC.text) {
      setState(() => err = 'Passwords do not match');
      return;
    }
    setState(() => load = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailC.text.trim(), password: passC.text.trim());
      final p = await SharedPreferences.getInstance();
      await p.setString('registered_email_permanent', cred.user!.email!.toLowerCase());
      await p.setBool('is_logged_in', true);
      await p.setBool('is_admin', cred.user!.email == 'mugabibenjamin14@gmail.com');
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNav(email: cred.user!.email!, isAdmin: false, onTheme: widget.onTheme)));
    } on FirebaseAuthException catch (e) {
      setState(() => err = e.message?? e.code);
    }
    setState(() => load = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, iconTheme: IconThemeData(color: Colors.white), title: Text('Register', style: TextStyle(color: Colors.white))),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(controller: emailC, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Email', filled: true, fillColor: Color(0xFF1C1C1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              SizedBox(height: 12),
              TextField(controller: passC, obscureText: true, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Password', filled: true, fillColor: Color(0xFF1C1C1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              SizedBox(height: 12),
              TextField(controller: confirmC, obscureText: true, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Confirm Password', filled: true, fillColor: Color(0xFF1C1C1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              if (err.isNotEmpty) Padding(padding: EdgeInsets.only(top: 10), child: Text(err, style: TextStyle(color: Colors.red))),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: load? null : signUp,
                  style: ElevatedButton.styleFrom(backgroundColor: kBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: load? IPhoneLoader() : Text('REGISTER', style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      );
}

class PasscodeLock extends StatefulWidget {
  final String email;
  final bool isAdmin;
  final VoidCallback onTheme;
  const PasscodeLock({super.key, required this.email, required this.isAdmin, required this.onTheme});
  @override
  State<PasscodeLock> createState() => PasscodeLockState();
}

class PasscodeLockState extends State<PasscodeLock> {
  String entered = '';
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    tryBio();
  }

  tryBio() async {
    final p = await SharedPreferences.getInstance();
    final useBio = p.getBool('use_biometric')?? false;
    if (useBio) {
      try {
        final ok = await auth.authenticate(localizedReason: 'Unlock Onyx Movies');
        if (ok && mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNav(email: widget.email, isAdmin: widget.isAdmin, onTheme: widget.onTheme)));
        }
      } catch (e) {}
    }
  }

  onNum(String n) async {
    if (entered.length < 6) {
      setState(() => entered += n);
    }
    if (entered.length == 6) {
      final p = await SharedPreferences.getInstance();
      final saved = p.getString('app_passcode');
      if (entered == saved) {
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNav(email: widget.email, isAdmin: widget.isAdmin, onTheme: widget.onTheme)));
      } else {
        setState(() => entered = '');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wrong passcode')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 60, color: kBlue),
            SizedBox(height: 10),
            Text('Enter 6-digit passcode', style: TextStyle(color: Colors.white)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) => Container(margin: EdgeInsets.all(6), width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: i < entered.length? kBlue : Colors.white24))),
            ),
            SizedBox(height: 30),
            GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 60),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 20),
              itemCount: 12,
              itemBuilder: (c, i) {
                if (i == 9) return IconButton(onPressed: tryBio, icon: Icon(Icons.fingerprint, color: kBlue));
                if (i == 10) return ElevatedButton(onPressed: () => onNum('0'), style: ElevatedButton.styleFrom(shape: CircleBorder(), backgroundColor: Color(0xFF1E1E1E)), child: Text('0', style: TextStyle(color: Colors.white, fontSize: 22)));
                if (i == 11) return IconButton(onPressed: () => setState(() => entered = entered.isNotEmpty? entered.substring(0, entered.length - 1) : ''), icon: Icon(Icons.backspace, color: Colors.white));
                final num = '${i + 1}';
                return ElevatedButton(onPressed: () => onNum(num), style: ElevatedButton.styleFrom(shape: CircleBorder(), backgroundColor: Color(0xFF1E1E1E)), child: Text(num, style: TextStyle(color: Colors.white, fontSize: 22)));
              },
            )
          ],
        ),
      );
}

class MainNav extends StatefulWidget {
  final String email;
  final bool isAdmin;
  final VoidCallback onTheme;
  const MainNav({super.key, required this.email, required this.isAdmin, required this.onTheme});
  @override
  State<MainNav> createState() => MainNavState();
}

class MainNavState extends State<MainNav> {
  int idx = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeFull(email: widget.email, isAdmin: widget.isAdmin),
      MoviesFullPage(),
      SeriesFullPage(),
      DownloadFullPage(),
      ProfileFull(email: widget.email, isAdmin: widget.isAdmin, onTheme: widget.onTheme)
    ];
    return Scaffold(
      backgroundColor: Colors.black,
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        backgroundColor: Color(0xFF0F172A),
        selectedItemColor: kBlue,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => idx = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Series'),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Downloads'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
        ],
      ),
    );
  }
}
class SafePoster extends StatelessWidget {
  final String base64Str;
  final double? h;
  final String? vjCorner;
  const SafePoster({super.key, required this.base64Str, this.h, this.vjCorner});
  @override
  Widget build(BuildContext context) {
    Widget img;
    if (base64Str.isEmpty || base64Str.length < 20) {
      img = Container(color: Color(0xFF1E1E1E), child: Icon(Icons.movie, color: Colors.white30, size: 40));
    } else {
      try {
        final bytes = base64Decode(base64Str);
        img = Image.memory(bytes, fit: BoxFit.cover, width: double.infinity, height: h, errorBuilder: (a, b, d) => Container(color: Color(0xFF1E1E1E), child: Icon(Icons.movie, color: Colors.white30)));
      } catch (e) {
        img = Container(color: Color(0xFF1E1E1E), child: Icon(Icons.movie, color: Colors.white30));
      }
    }
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: img),
        if (vjCorner!= null && vjCorner!.isNotEmpty)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: kBlue, borderRadius: BorderRadius.circular(6)),
              child: Text(vjCorner!, style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          )
      ],
    );
  }
}

class LiquidSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onNotif;
  final VoidCallback onDownload;
  const LiquidSearchBar({super.key, required this.onTap, required this.onNotif, required this.onDownload});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 46,
                decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    Icon(Icons.search, color: Colors.white70, size: 18),
                    SizedBox(width: 8),
                    Text('Search movies, VJ, genre...', style: TextStyle(color: Colors.white70, fontSize: 13))
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(width: 46, height: 46, decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)), child: IconButton(icon: Icon(Icons.notifications_none, color: Colors.white, size: 20), onPressed: onNotif)),
          SizedBox(width: 8),
          Container(width: 46, height: 46, decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)), child: IconButton(icon: Icon(Icons.download_outlined, color: Colors.white, size: 20), onPressed: onDownload)),
        ],
      ),
    );
  }
}

class HomeFull extends StatefulWidget {
  final String email;
  final bool isAdmin;
  const HomeFull({super.key, required this.email, required this.isAdmin});
  @override
  State<HomeFull> createState() => HomeFullState();
}

class HomeFullState extends State<HomeFull> {
  DatabaseReference? ref;
  DatabaseReference? refVj;
  DatabaseReference? refGenres;
  List<String> vjList = ['All'];
  List<String> genreList = ['All'];
  List<String> favIds = [];

  @override
  void initState() {
    super.initState();
    try {
      ref = FirebaseDatabase.instance.ref('movies');
      refVj = FirebaseDatabase.instance.ref('settings/vj_names');
      refGenres = FirebaseDatabase.instance.ref('settings/genres');
    } catch (e) {}
    loadCats();
    loadFav();
  }

  loadCats() async {
    try {
      final s1 = await refVj?.get();
      if (s1!= null && s1.value!= null) {
        final m = Map<String, dynamic>.from(s1.value as Map);
        setState(() => vjList = ['All',...m.values.map((e) => e.toString())]);
      }
    } catch (e) {}
    try {
      final s2 = await refGenres?.get();
      if (s2!= null && s2.value!= null) {
        final m = Map<String, dynamic>.from(s2.value as Map);
        setState(() => genreList = ['All',...m.values.map((e) => e.toString())]);
      }
    } catch (e) {}
  }

  loadFav() async {
    final p = await SharedPreferences.getInstance();
    setState(() => favIds = p.getStringList('favs')?? []);
  }

  toggleFav(String id) async {
    final p = await SharedPreferences.getInstance();
    if (favIds.contains(id))
      favIds.remove(id);
    else
      favIds.add(id);
    await p.setStringList('favs', favIds);
    setState(() {});
  }

  openSearch() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) {
        String selVj = 'All';
        String selGenre = 'All';
        return StatefulBuilder(
          builder: (c, setM) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text('Search by Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 12),
                  Text('VJ', style: TextStyle(color: Colors.white70)),
                  Wrap(
                    spacing: 6,
                    children: vjList.map((v) => ChoiceChip(
                      label: Text(v, style: TextStyle(fontSize: 11)),
                      selected: selVj == v,
                      selectedColor: kBlue,
                      onSelected: (s) {
                        setM(() => selVj = v);
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => FilterPage(vj: selVj, genre: selGenre)));
                      },
                    )).toList(),
                  ),
                  SizedBox(height: 12),
                  Text('Genre', style: TextStyle(color: Colors.white70)),
                  Wrap(
                    spacing: 6,
                    children: genreList.map((g) => ChoiceChip(
                      label: Text(g, style: TextStyle(fontSize: 11)),
                      selected: selGenre == g,
                      selectedColor: kBlue,
                      onSelected: (s) {
                        setM(() => selGenre = g);
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => FilterPage(vj: selVj, genre: g)));
                      },
                    )).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget section(String title, List<MapEntry<String, dynamic>> items) {
    if (items.isEmpty) return SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SeeMorePage(title: title, items: items))), child: Text('See More', style: TextStyle(color: kBlue, fontSize: 12)))
            ],
          ),
        ),
        SizedBox(
          height: 135,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (c, i) {
              final m = Map<String, dynamic>.from(items[i].value as Map);
              final isFav = favIds.contains(items[i].key);
              return GestureDetector(
                onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => PlayerPage(movie: m, id: items[i].key, onFav: () {
                  toggleFav(items[i].key);
                }, isFav: isFav))),
                child: Container(
                  width: 110,
                  margin: EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            SafePoster(base64Str: m['posterBase64']?? '', vjCorner: m['vj']?? ''),
                            if (isFav) Positioned(top: 4, left: 4, child: Icon(Icons.favorite, size: 14, color: Colors.red))
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(m['title']?? '', style: TextStyle(color: Colors.white, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis)
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (ref == null) {
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 60, color: Colors.red),
              SizedBox(height: 12),
              Text('Firebase not configured!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            ],
          ),
        ),
      );
    }
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: LiquidSearchBar(onTap: openSearch, onNotif: () {}, onDownload: () {})),
          SliverToBoxAdapter(
            child: StreamBuilder(
              stream: ref!.orderByChild('timestamp').limitToLast(7).onValue,
              builder: (c, snap) {
                if (!snap.hasData || snap.data!.snapshot.value == null)
                  return Container(
                    height: 220,
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [IPhoneLoader(), SizedBox(height: 10), Text('No movies yet', style: TextStyle(color: Colors.white54))],
                      ),
                    ),
                  );
                final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
                final list = map.entries.toList()
                 ..sort((a, b) {
                    final at = Map<String, dynamic>.from(a.value as Map)['timestamp']?? 0;
                    final bt = Map<String, dynamic>.from(b.value as Map)['timestamp']?? 0;
                    return bt.compareTo(at);
                  });
                return SizedBox(
                  height: 260,
                  child: PageView.builder(
                    itemCount: list.length,
                    itemBuilder: (c, i) {
                      final m = Map<String, dynamic>.from(list[i].value as Map);
                      final isFav = favIds.contains(list[i].key);
                      return GestureDetector(
                        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => PlayerPage(movie: m, id: list[i].key, onFav: () {
                          toggleFav(list[i].key);
                        }, isFav: isFav))),
                        child: Container(
                          margin: EdgeInsets.all(12),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Color(0xFF1E293B)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                SafePoster(base64Str: m['posterBase64']?? ''),
                                Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.85)]))),
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: kBlue, borderRadius: BorderRadius.circular(6)), child: Text(m['genre']?? 'Action', style: TextStyle(color: Colors.white, fontSize: 9))),
                                          SizedBox(width: 6),
                                          Text(m['year']?? '2024', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                          Spacer(),
                                          IconButton(icon: Icon(isFav? Icons.favorite : Icons.favorite_border, color: isFav? Colors.red : Colors.white, size: 20), onPressed: () {
                                            toggleFav(list[i].key);
                                          })
                                        ],
                                      ),
                                      Text(m['title']?? '', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                                      Text(m['description']?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white70, fontSize: 11)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder(
              stream: ref!.onValue,
              builder: (c, snap) {
                if (!snap.hasData || snap.data!.snapshot.value == null)
                  return Padding(padding: EdgeInsets.all(20), child: Center(child: Text('Upload movies in Admin Panel', style: TextStyle(color: Colors.white38))));
                final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
                var all = map.entries.toList()
                 ..sort((a, b) {
                    final at = Map<String, dynamic>.from(a.value as Map)['timestamp']?? 0;
                    final bt = Map<String, dynamic>.from(b.value as Map)['timestamp']?? 0;
                    return bt.compareTo(at);
                  });
                var movies = all.where((e) {
                  final m = Map<String, dynamic>.from(e.value as Map);
                  return (m['type']?? 'movie')!= 'series';
                }).toList();
                var series = all.where((e) {
                  final m = Map<String, dynamic>.from(e.value as Map);
                  return m['type'] == 'series';
                }).toList();
                var anim = movies.where((e) {
                  final m = Map<String, dynamic>.from(e.value as Map);
                  return (m['genre']?? '').toString().toLowerCase().contains('anim');
                }).toList();
                var indian = movies.where((e) {
                  final m = Map<String, dynamic>.from(e.value as Map);
                  return (m['genre']?? '').toString().toLowerCase().contains('indian') || (m['category']?? '').toString().toLowerCase().contains('indian');
                }).toList();
                var trending = movies.take(10).toList();
                return Column(
                  children: [
                    section('Latest Release', movies),
                    section('Latest Series', series),
                    section('Trending Movies', trending),
                    section('Animations', anim.isEmpty? movies.take(5).toList() : anim),
                    section('Indian Movies', indian.isEmpty? movies.take(5).toList() : indian),
                    SizedBox(height: 20),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class FilterPage extends StatelessWidget {
  final String vj;
  final String genre;
  const FilterPage({super.key, required this.vj, required this.genre});
  @override
  Widget build(BuildContext context) {
    DatabaseReference? ref;
    try {
      ref = FirebaseDatabase.instance.ref('movies');
    } catch (e) {
      return Scaffold(backgroundColor: Colors.black, body: Center(child: Text('Firebase not configured', style: TextStyle(color: Colors.white))));
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text('Filter: $vj | $genre', style: TextStyle(fontSize: 13))),
      body: StreamBuilder(
        stream: ref!.onValue,
        builder: (c, snap) {
          if (!snap.hasData) return Center(child: IPhoneLoader());
          if (snap.data!.snapshot.value == null) return Center(child: Text('No movies', style: TextStyle(color: Colors.white54)));
          final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
          var list = map.entries.where((e) {
            final m = Map<String, dynamic>.from(e.value as Map);
            bool okVj = vj == 'All' || (m['vj']?? '').toString() == vj;
            bool okG = genre == 'All' || (m['genre']?? '').toString() == genre || (m['category']?? '').toString() == genre;
            return okVj && okG;
          }).toList();
          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: list.length,
            itemBuilder: (c, i) {
              final m = Map<String, dynamic>.from(list[i].value as Map);
              return GestureDetector(
                onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => PlayerPage(movie: m, id: list[i].key, onFav: () {}, isFav: false))),
                child: Card(color: Color(0xFF1E293B), child: Column(children: [Expanded(child: SafePoster(base64Str: m['posterBase64']?? '', vjCorner: m['vj'])), Padding(padding: EdgeInsets.all(6), child: Text(m['title']?? '', style: TextStyle(color: Colors.white, fontSize: 11)))])),
              );
            },
          );
        },
      ),
    );
  }
}

class SeeMorePage extends StatelessWidget {
  final String title;
  final List<MapEntry<String, dynamic>> items;
  const SeeMorePage({super.key, required this.title, required this.items});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text(title, style: TextStyle(fontSize: 14))),
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: items.length,
        itemBuilder: (c, i) {
          final m = Map<String, dynamic>.from(items[i].value as Map);
          return GestureDetector(
            onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => PlayerPage(movie: m, id: items[i].key, onFav: () {}, isFav: false))),
            child: Card(color: Color(0xFF1E293B), child: Column(children: [Expanded(child: SafePoster(base64Str: m['posterBase64']?? '', vjCorner: m['vj'])), Padding(padding: EdgeInsets.all(6), child: Text(m['title']?? '', style: TextStyle(color: Colors.white, fontSize: 11)))])),
          );
        },
      ),
    );
  }
}

class MoviesFullPage extends StatelessWidget {
  const MoviesFullPage({super.key});
  @override
  Widget build(BuildContext context) {
    DatabaseReference? ref;
    try {
      ref = FirebaseDatabase.instance.ref('movies');
    } catch (e) {
      return SafeArea(child: Center(child: Text('Firebase not configured', style: TextStyle(color: Colors.white))));
    }
    return SafeArea(
      child: StreamBuilder(
        stream: ref!.orderByChild('timestamp').onValue,
        builder: (c, snap) {
          if (!snap.hasData) return Center(child: IPhoneLoader());
          if (snap.data!.snapshot.value == null) return Center(child: Text('No movies - Upload in Admin', style: TextStyle(color: Colors.white54)));
          final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
          var list = map.entries.where((e) {
            final m = Map<String, dynamic>.from(e.value as Map);
            return (m['type']?? 'movie')!= 'series';
          }).toList()
           ..sort((a, b) {
              final at = Map<String, dynamic>.from(a.value as Map)['timestamp']?? 0;
              final bt = Map<String, dynamic>.from(b.value as Map)['timestamp']?? 0;
              return bt.compareTo(at);
            });
          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: list.length,
            itemBuilder: (c, i) {
              final m = Map<String, dynamic>.from(list[i].value as Map);
              return GestureDetector(
                onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => PlayerPage(movie: m, id: list[i].key, onFav: () {}, isFav: false))),
                child: Card(color: Color(0xFF1E293B), child: Column(children: [Expanded(child: SafePoster(base64Str: m['posterBase64']?? '', vjCorner: m['vj'])), Padding(padding: EdgeInsets.all(6), child: Text(m['title']?? '', style: TextStyle(color: Colors.white, fontSize: 11)))])),
              );
            },
          );
        },
      ),
    );
  }
}

class SeriesFullPage extends StatelessWidget {
  const SeriesFullPage({super.key});
  @override
  Widget build(BuildContext context) {
    DatabaseReference? ref;
    try {
      ref = FirebaseDatabase.instance.ref('movies');
    } catch (e) {
      return SafeArea(child: Center(child: Text('Firebase not configured', style: TextStyle(color: Colors.white))));
    }
    return SafeArea(
      child: StreamBuilder(
        stream: ref!.orderByChild('timestamp').onValue,
        builder: (c, snap) {
          if (!snap.hasData) return Center(child: IPhoneLoader());
          if (snap.data!.snapshot.value == null) return Center(child: Text('No series', style: TextStyle(color: Colors.white54)));
          final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
          var list = map.entries.where((e) {
            final m = Map<String, dynamic>.from(e.value as Map);
            return m['type'] == 'series';
          }).toList()
           ..sort((a, b) {
              final at = Map<String, dynamic>.from(a.value as Map)['timestamp']?? 0;
              final bt = Map<String, dynamic>.from(b.value as Map)['timestamp']?? 0;
              return bt.compareTo(at);
            });
          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: list.length,
            itemBuilder: (c, i) {
              final m = Map<String, dynamic>.from(list[i].value as Map);
              return GestureDetector(
                onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => PlayerPage(movie: m, id: list[i].key, onFav: () {}, isFav: false))),
                child: Card(color: Color(0xFF1E293B), child: Column(children: [Expanded(child: SafePoster(base64Str: m['posterBase64']?? '', vjCorner: m['vj'])), Padding(padding: EdgeInsets.all(6), child: Text(m['title']?? '', style: TextStyle(color: Colors.white, fontSize: 11)))])),
              );
            },
          );
        },
      ),
    );
  }
}
class PlayerPage extends StatefulWidget {
  final Map<String, dynamic> movie;
  final String id;
  final VoidCallback onFav;
  final bool isFav;
  const PlayerPage({super.key, required this.movie, required this.id, required this.onFav, required this.isFav});
  @override
  State<PlayerPage> createState() => PlayerPageState();
}

class PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? ctrl;
  bool isDownloading = false;
  double dlProgress = 0;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  initVideo() {
    final url = widget.movie['downloadUrl']?.toString();
    if (url!= null && url.startsWith('http')) {
      try {
        ctrl = VideoPlayerController.networkUrl(Uri.parse(url))..initialize().then((_) => setState(() {}));
      } catch (e) {}
    }
  }

  downloadFile() async {
    try {
      await Permission.storage.request();
      final url = widget.movie['downloadUrl']?.toString();
      if (url == null || url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No download URL')));
        return;
      }
      setState(() => isDownloading = true);
      final dir = await getExternalStorageDirectory();
      final folder = Directory('${dir!.path}/OnyxMovies');
      if (!await folder.exists()) await folder.create(recursive: true);
      final savePath = '${folder.path}/${widget.movie['title']?? 'movie'}.mp4';
      final dio = Dio();
      await dio.download(url, savePath, onReceiveProgress: (rec, total) {
        if (total!= -1) setState(() => dlProgress = rec / total);
      });
      final p = await SharedPreferences.getInstance();
      final list = p.getStringList('downloaded_files')?? [];
      list.add(savePath);
      await p.setStringList('downloaded_files', list);
      setState(() => isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded'), backgroundColor: Colors.green));
    } catch (e) {
      setState(() => isDownloading = false);
    }
  }

  shareMovie() {
    final title = widget.movie['title']?? 'Movie';
    final url = widget.movie['downloadUrl']?? '';
    Share.share('Watch $title on ONYX MOVIES App Link: $url');
  }

  @override
  void dispose() {
    ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final casts = widget.movie['casts']!= null? List.from(widget.movie['casts']) : [];
    final eps = widget.movie['episodes']!= null? List.from(widget.movie['episodes']) : [];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.movie['title']?? '', style: TextStyle(fontSize: 14)),
        actions: [
          IconButton(icon: Icon(Icons.share, color: Colors.white), onPressed: shareMovie),
          IconButton(icon: Icon(widget.isFav? Icons.favorite : Icons.favorite_border, color: widget.isFav? Colors.red : Colors.white), onPressed: widget.onFav)
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
                  child: ctrl!= null && ctrl!.value.isInitialized? ClipRRect(borderRadius: BorderRadius.circular(16), child: VideoPlayer(ctrl!)) : Center(child: SafePoster(base64Str: widget.movie['posterBase64']?? '')),
                ),
                Positioned.fill(
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.play_circle_fill, size: 70, color: kBlue.withOpacity(0.9)),
                      onPressed: () {
                        if (ctrl!= null) {
                          if (ctrl!.value.isPlaying)
                            ctrl!.pause();
                          else
                            ctrl!.play();
                          setState(() {});
                        } else {
                          downloadFile();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ElevatedButton.icon(onPressed: isDownloading? null : downloadFile, icon: Icon(Icons.download), label: Text(isDownloading? '${(dlProgress * 100).toStringAsFixed(0)}%' : 'Download'), style: ElevatedButton.styleFrom(backgroundColor: kBlue))),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  final url = widget.movie['downloadUrl'];
                  if (url!= null) {
                    final uri = Uri.parse(url);
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: Icon(Icons.play_arrow),
                label: Text('Play'),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E293B)),
              ),
              SizedBox(width: 8),
              ElevatedButton(onPressed: shareMovie, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E293B)), child: Icon(Icons.share, color: Colors.white))
            ],
          ),
          if (isDownloading) LinearProgressIndicator(value: dlProgress, color: kBlue, backgroundColor: Colors.white24),
          SizedBox(height: 14),
          Text(widget.movie['title']?? '', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Row(
            children: [
              Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: kBlue, borderRadius: BorderRadius.circular(6)), child: Text(widget.movie['genre']?? 'Action', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              SizedBox(width: 8),
              Text('VJ: ${widget.movie['vj']?? ''}', style: TextStyle(color: Colors.white54, fontSize: 12))
            ],
          ),
          SizedBox(height: 10),
          Text(widget.movie['description']?? 'No description', style: TextStyle(color: Colors.white70, fontSize: 13)),
          SizedBox(height: 16),
          if (casts.isNotEmpty)...[
            Text('Casts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            SizedBox(height: 8),
            SizedBox(
              height: 85,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: casts.length,
                itemBuilder: (c, i) {
                  final cast = Map<String, dynamic>.from(casts[i] as Map);
                  return Container(
                    width: 65,
                    margin: EdgeInsets.only(right: 10),
                    child: Column(
                      children: [
                        CircleAvatar(radius: 28, backgroundColor: Color(0xFF1E293B)),
                        SizedBox(height: 5),
                        Text(cast['name']?? '', style: TextStyle(color: Colors.white, fontSize: 9))
                      ],
                    ),
                  );
                },
              ),
            )
          ],
          if (eps.isNotEmpty)...[
            SizedBox(height: 18),
            Text('Episodes (${eps.length})', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            SizedBox(height: 8),
           ...eps.asMap().entries.map((e) {
              final ep = Map<String, dynamic>.from(e.value as Map);
              return Card(
                color: Color(0xFF1E293B),
                child: ListTile(
                  title: Text(ep['title']?? 'Episode ${e.key + 1}', style: TextStyle(color: Colors.white, fontSize: 13)),
                  trailing: IconButton(
                    icon: Icon(Icons.play_arrow, color: kBlue),
                    onPressed: () async {
                      final u = ep['url']?? '';
                      if (u.isNotEmpty) {
                        final uri = Uri.parse(u);
                        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ),
              );
            })
          ]
        ],
      ),
    );
  }
}

class DownloadFullPage extends StatefulWidget {
  const DownloadFullPage({super.key});
  @override
  State<DownloadFullPage> createState() => DownloadFullPageState();
}

class DownloadFullPageState extends State<DownloadFullPage> {
  List<String> downloaded = [];
  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    final p = await SharedPreferences.getInstance();
    setState(() => downloaded = p.getStringList('downloaded_files')?? []);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(color: Color(0xFF0F172A), child: TabBar(labelColor: kBlue, unselectedLabelColor: Colors.white54, indicatorColor: kBlue, tabs: [Tab(icon: Icon(Icons.downloading), text: 'Downloading'), Tab(icon: Icon(Icons.download_done), text: 'Downloaded')])),
            Expanded(
              child: TabBarView(
                children: [
                  Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [IPhoneLoader(), SizedBox(height: 12), Text('Progress shows in Player', style: TextStyle(color: Colors.white54, fontSize: 12))])),
                  downloaded.isEmpty
                    ? Center(child: Text('No files yet', style: TextStyle(color: Colors.white54)))
                      : ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: downloaded.length,
                          itemBuilder: (c, i) => Card(
                            color: Color(0xFF1E293B),
                            child: ListTile(
                              leading: Icon(Icons.movie, color: kBlue),
                              title: Text(downloaded[i].split('/').last, style: TextStyle(color: Colors.white, fontSize: 11)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                onPressed: () async {
                                  final p = await SharedPreferences.getInstance();
                                  downloaded.removeAt(i);
                                  await p.setStringList('downloaded_files', downloaded);
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                        )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProfileFull extends StatefulWidget {
  final String email;
  final bool isAdmin;
  final VoidCallback onTheme;
  const ProfileFull({super.key, required this.email, required this.isAdmin, required this.onTheme});
  @override
  State<ProfileFull> createState() => ProfileFullState();
}

class ProfileFullState extends State<ProfileFull> {
  bool dark = true;
  bool highSpeed = false;
  bool allowPerm = false;
  bool useBio = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      dark = p.getBool('dark_mode')?? true;
      highSpeed = p.getBool('high_speed')?? false;
      allowPerm = p.getBool('allow_perm')?? false;
      useBio = p.getBool('use_biometric')?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SizedBox(height: 10),
          Center(child: CircleAvatar(radius: 45, backgroundColor: Color(0xFF1E293B), child: Icon(Icons.person, size: 45, color: kBlue))),
          SizedBox(height: 12),
          Text(widget.email, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(widget.isAdmin? 'Admin Account' : 'User Account', textAlign: TextAlign.center, style: TextStyle(color: widget.isAdmin? kBlue : Colors.white54, fontSize: 11)),
          SizedBox(height: 20),
          if (widget.isAdmin)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPanelFull(email: widget.email))),
                icon: Icon(Icons.admin_panel_settings, color: Colors.white),
                label: Text('ADMIN PANEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: kBlue),
              ),
            ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () async {
                final p = await SharedPreferences.getInstance();
                await p.clear();
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen(onTheme: widget.onTheme)));
              },
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text('LOGOUT'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          )
        ],
      ),
    );
  }
}

class AdminPanelFull extends StatefulWidget {
  final String email;
  const AdminPanelFull({super.key, required this.email});
  @override
  State<AdminPanelFull> createState() => AdminPanelFullState();
}

class AdminPanelFullState extends State<AdminPanelFull> {
  int idx = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [AdminDashFull(email: widget.email), AdminMovieFull(), AdminSeriesFull(), AdminBannerFull(), AdminManageFull(), AdminSettingsFull()];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text('ADMIN: ${widget.email}', style: TextStyle(fontSize: 11, color: kBlue))),
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        backgroundColor: Color(0xFF0F172A),
        selectedItemColor: kBlue,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => idx = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dash'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Series'),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Banners'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Manage'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
        ],
      ),
    );
  }
}

class AdminDashFull extends StatelessWidget {
  final String email;
  AdminDashFull({super.key, required this.email});
  @override
  Widget build(BuildContext context) {
    DatabaseReference? ref;
    try {
      ref = FirebaseDatabase.instance.ref('movies');
    } catch (e) {
      return Center(child: Text('Firebase not configured', style: TextStyle(color: Colors.white)));
    }
    return StreamBuilder(
      stream: ref!.onValue,
      builder: (c, snap) {
        int total = 0, movies = 0, series = 0;
        if (snap.hasData && snap.data!.snapshot.value!= null) {
          final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
          total = map.length;
          for (var v in map.values) {
            final m = Map<String, dynamic>.from(v as Map);
            if (m['type'] == 'series')
              series++;
            else
              movies++;
          }
        }
        return ListView(
          padding: EdgeInsets.all(12),
          children: [
            Card(
              color: Color(0xFF1E293B),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(email, style: TextStyle(color: kBlue, fontSize: 11)),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Card(color: Color(0xFF0F172A), child: Padding(padding: EdgeInsets.all(12), child: Column(children: [Text('$total', style: TextStyle(color: Colors.white, fontSize: 20)), Text('Total', style: TextStyle(color: Colors.white54, fontSize: 10))])))),
                        Expanded(child: Card(color: Color(0xFF0F172A), child: Padding(padding: EdgeInsets.all(12), child: Column(children: [Text('$movies', style: TextStyle(color: Colors.white, fontSize: 20)), Text('Movies', style: TextStyle(color: Colors.white54, fontSize: 10))])))),
                        Expanded(child: Card(color: Color(0xFF0F172A), child: Padding(padding: EdgeInsets.all(12), child: Column(children: [Text('$series', style: TextStyle(color: Colors.white, fontSize: 20)), Text('Series', style: TextStyle(color: Colors.white54, fontSize: 10))]))))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AdminManageFull extends StatelessWidget {
  const AdminManageFull({super.key});
  @override
  Widget build(BuildContext context) {
    DatabaseReference? ref;
    try {
      ref = FirebaseDatabase.instance.ref('movies');
    } catch (e) {
      return Center(child: Text('Firebase not configured', style: TextStyle(color: Colors.white)));
    }
    return StreamBuilder(
      stream: ref!.onValue,
      builder: (c, snap) {
        if (!snap.hasData) return Center(child: IPhoneLoader());
        if (snap.data!.snapshot.value == null) return Center(child: Text('No data', style: TextStyle(color: Colors.white54)));
        final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
        final list = map.entries.toList();
        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: list.length,
          itemBuilder: (c, i) {
            final m = Map<String, dynamic>.from(list[i].value as Map);
            return Card(
              color: Color(0xFF1E1E1E),
              child: ListTile(
                leading: SizedBox(width: 45, height: 45, child: SafePoster(base64Str: m['posterBase64']?? '')),
                title: Text(m['title']?? '', style: TextStyle(color: Colors.white, fontSize: 12)),
                trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () async {
                  await ref!.child(list[i].key).remove();
                }),
              ),
            );
          },
        );
      },
    );
  }
}

class AdminMovieFull extends StatefulWidget {
  const AdminMovieFull({super.key});
  @override
  State<AdminMovieFull> createState() => AdminMovieFullState();
}

class AdminMovieFullState extends State<AdminMovieFull> {
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final yearC = TextEditingController();
  final vjC = TextEditingController();
  String genre = 'Action';
  String category = 'Latest Release';
  String location = 'Latest';
  Uint8List? poster;
  final picker = ImagePicker();
  bool up = false;
  double progress = 0;
  String status = '';
  PlatformFile? videoFile;
  List<String> genres = ['Action', 'Animation', 'Indian', 'Trending', 'Comedy', 'Horror', 'Sci-Fi'];
  List<String> locations = ['Latest Release', 'Trending Movies', 'Animations', 'Indian Movies', 'Latest'];

  pickPoster() async {
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 10, maxWidth: 400);
    if (x!= null) {
      final b = await x.readAsBytes();
      setState(() => poster = b);
    }
  }

  pickVideo() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.video, withData: false);
    if (r!= null && r.files.first.path!= null) {
      setState(() => videoFile = r.files.first);
    }
  }

  upload() async {
    if (titleC.text.isEmpty || poster == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Title + Poster required')));
      return;
    }
    if (videoFile == null || videoFile!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pick movie file')));
      return;
    }
    setState(() => up = true);
    try {
      final file = File(videoFile!.path!);
      final fileSizeGB = await file.length() / (1024 * 1024 * 1024);
      setState(() => status = 'Starting ${fileSizeGB.toStringAsFixed(2)}GB upload...');
      final sRef = FirebaseStorage.instance.ref().child('movies/${DateTime.now().millisecondsSinceEpoch}_${videoFile!.name}');
      final task = sRef.putFile(file, SettableMetadata(contentType: 'video/mp4'));
      task.snapshotEvents.listen((s) {
        final upGB = s.bytesTransferred / (1024 * 1024 * 1024);
        final totGB = s.totalBytes / (1024 * 1024 * 1024);
        setState(() {
          progress = s.bytesTransferred / s.totalBytes;
          status = '${upGB.toStringAsFixed(2)}GB / ${totGB.toStringAsFixed(2)}GB ${(progress * 100).toStringAsFixed(1)}%';
        });
      });
      final snap = await task.timeout(Duration(hours: 3));
      final url = await snap.ref.getDownloadURL();
      final ref = FirebaseDatabase.instance.ref('movies').push();
      await ref.set({
        'title': titleC.text,
        'description': descC.text,
        'posterBase64': base64Encode(poster!),
        'downloadUrl': url,
        'year': yearC.text,
        'genre': genre,
        'category': category,
        'location': location,
        'vj': vjC.text.isEmpty? 'VJ Junior' : vjC.text,
        'type': 'movie',
        'timestamp': ServerValue.timestamp,
        'fileSizeGB': fileSizeGB
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('UPLOADED ${fileSizeGB.toStringAsFixed(2)}GB SUCCESS!'), backgroundColor: Colors.green));
      setState(() {
        poster = null;
        videoFile = null;
        progress = 0;
        status = '';
      });
      titleC.clear();
      descC.clear();
      yearC.clear();
      vjC.clear();
    } catch (e) {
      setState(() => status = 'Error $e');
    }
    setState(() => up = false);
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: EdgeInsets.all(12),
        children: [
          Text('Upload Movie - 6GB SUPPORT', style: TextStyle(color: kBlue, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(controller: titleC, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          SizedBox(height: 8),
          TextField(controller: descC, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TextField(controller: yearC, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Year', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
              SizedBox(width: 8),
              Expanded(child: TextField(controller: vjC, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'VJ Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
            ],
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(onPressed: pickPoster, icon: Icon(Icons.image), label: Text(poster == null? 'Pick Poster' : 'Poster OK'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E293B))),
          if (poster!= null) Container(height: 100, margin: EdgeInsets.only(top: 6), child: Image.memory(poster!)),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: pickVideo,
            icon: Icon(Icons.video_file),
            label: Text(videoFile == null? 'Pick Movie File (UP TO 6GB)' : 'Video OK: ${videoFile!.name} (${(videoFile!.size / 1024 / 1024 / 1024).toStringAsFixed(2)}GB)'),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E293B)),
          ),
          if (up)...[
            SizedBox(height: 12),
            LinearProgressIndicator(value: progress, color: kBlue),
            SizedBox(height: 4),
            Text(status, style: TextStyle(color: kBlue, fontSize: 11))
          ],
          SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: up? null : upload,
              style: ElevatedButton.styleFrom(backgroundColor: kBlue),
              child: Text(up? status : 'UPLOAD MOVIE (6GB READY)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
}

class AdminSeriesFull extends StatefulWidget {
  const AdminSeriesFull({super.key});
  @override
  State<AdminSeriesFull> createState() => AdminSeriesFullState();
}

class AdminSeriesFullState extends State<AdminSeriesFull> {
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final vjC = TextEditingController();
  final seasonC = TextEditingController();
  Uint8List? poster;
  final picker = ImagePicker();
  bool up = false;
  List<Map<String, dynamic>> episodes = [];
  final epTitleC = TextEditingController();
  PlatformFile? epFile;
  bool epUp = false;
  double epProg = 0;

  pickPoster() async {
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 10, maxWidth: 400);
    if (x!= null) {
      final b = await x.readAsBytes();
      setState(() => poster = b);
    }
  }

  pickEpFile() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.video, withData: false);
    if (r!= null && r.files.first.path!= null) {
      setState(() => epFile = r.files.first);
    }
  }

  addEp() async {
    if (epTitleC.text.isEmpty || epFile == null) return;
    setState(() => epUp = true);
    try {
      final file = File(epFile!.path!);
      final sRef = FirebaseStorage.instance.ref().child('series/${DateTime.now().millisecondsSinceEpoch}_${epFile!.name}');
      final task = sRef.putFile(file, SettableMetadata(contentType: 'video/mp4'));
      task.snapshotEvents.listen((s) {
        setState(() => epProg = s.bytesTransferred / s.totalBytes);
      });
      final snap = await task.timeout(Duration(hours: 3));
      final url = await snap.ref.getDownloadURL();
      setState(() => episodes.add({'title': epTitleC.text, 'url': url}));
      epTitleC.clear();
      epFile = null;
      epProg = 0;
    } catch (e) {}
    setState(() => epUp = false);
  }

  uploadSeries() async {
    if (titleC.text.isEmpty || poster == null) return;
    if (episodes.isEmpty) return;
    setState(() => up = true);
    try {
      final ref = FirebaseDatabase.instance.ref('movies').push();
      await ref.set({
        'title': titleC.text,
        'description': descC.text,
        'posterBase64': base64Encode(poster!),
        'vj': vjC.text,
        'season': seasonC.text,
        'type': 'series',
        'episodes': episodes,
        'timestamp': ServerValue.timestamp
      });
      setState(() {
        poster = null;
        episodes = [];
      });
      titleC.clear();
      descC.clear();
      vjC.clear();
      seasonC.clear();
    } catch (e) {}
    setState(() => up = false);
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: EdgeInsets.all(12),
        children: [
          Text('Upload Series - 6GB SUPPORT', style: TextStyle(color: kBlue, fontWeight: FontWeight.bold)),
          TextField(controller: titleC, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Series Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          SizedBox(height: 8),
          ElevatedButton(onPressed: pickPoster, child: Text(poster == null? 'Pick Poster' : 'Poster OK')),
          if (poster!= null) Container(height: 100, child: Image.memory(poster!)),
          SizedBox(height: 12),
          TextField(controller: epTitleC, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Episode Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          SizedBox(height: 6),
          ElevatedButton.icon(onPressed: pickEpFile, icon: Icon(Icons.video_file), label: Text(epFile == null? 'Pick Episode File' : 'File OK: ${epFile!.name}'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E293B))),
          if (epUp) LinearProgressIndicator(value: epProg, color: kBlue),
          SizedBox(height: 8),
          ElevatedButton(onPressed: addEp, child: Text('UPLOAD EPISODE')),
         ...episodes.map((e) => Card(color: Color(0xFF1E293B), child: ListTile(title: Text(e['title']?? '', style: TextStyle(color: Colors.white)), trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () {
            setState(() => episodes.remove(e));
          })))),
          SizedBox(height: 16),
          ElevatedButton(onPressed: up? null : uploadSeries, style: ElevatedButton.styleFrom(backgroundColor: kBlue), child: Text('UPLOAD SERIES')),
        ],
      );
}

class AdminBannerFull extends StatefulWidget {
  const AdminBannerFull({super.key});
  @override
  State<AdminBannerFull> createState() => AdminBannerFullState();
}

class AdminBannerFullState extends State<AdminBannerFull> {
  final titleC = TextEditingController();
  Uint8List? img;
  final picker = ImagePicker();
  bool up = false;

  pick() async {
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 10, maxWidth: 600);
    if (x!= null) {
      final b = await x.readAsBytes();
      setState(() => img = b);
    }
  }

  upload() async {
    if (titleC.text.isEmpty || img == null) return;
    setState(() => up = true);
    final ref = FirebaseDatabase.instance.ref('banners').push();
    await ref.set({'title': titleC.text, 'imageBase64': base64Encode(img!), 'timestamp': ServerValue.timestamp});
    setState(() => up = false);
    titleC.clear();
    img = null;
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference? ref;
    try {
      ref = FirebaseDatabase.instance.ref('banners');
    } catch (e) {
      return Center(child: Text('Firebase not configured', style: TextStyle(color: Colors.white)));
    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(controller: titleC, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Banner Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              SizedBox(height: 8),
              ElevatedButton(onPressed: pick, child: Text(img == null? 'Pick Image' : 'Image OK')),
              if (img!= null) Container(height: 80, child: Image.memory(img!)),
              SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: up? null : upload, style: ElevatedButton.styleFrom(backgroundColor: kBlue), child: Text('ADD BANNER')))
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: ref!.onValue,
            builder: (c, snap) {
              if (!snap.hasData || snap.data!.snapshot.value == null) return Center(child: Text('No banners', style: TextStyle(color: Colors.white54)));
              final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
              final list = map.entries.toList();
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (c, i) {
                  final m = Map<String, dynamic>.from(list[i].value as Map);
                  return Card(
                    color: Color(0xFF1E293B),
                    child: ListTile(
                      leading: SizedBox(width: 50, child: SafePoster(base64Str: m['imageBase64']?? '')),
                      title: Text(m['title']?? '', style: TextStyle(color: Colors.white)),
                      trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () async {
                        await ref!.child(list[i].key).remove();
                      }),
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}

class AdminSettingsFull extends StatefulWidget {
  const AdminSettingsFull({super.key});
  @override
  State<AdminSettingsFull> createState() => AdminSettingsFullState();
}

class AdminSettingsFullState extends State<AdminSettingsFull> {
  final vjC = TextEditingController();
  final genreC = TextEditingController();
  final refVj = FirebaseDatabase.instance.ref('settings/vj_names');
  final refGenre = FirebaseDatabase.instance.ref('settings/genres');

  addVj() async {
    if (vjC.text.isEmpty) return;
    await refVj.push().set(vjC.text);
    vjC.clear();
  }

  addGenre() async {
    if (genreC.text.isEmpty) return;
    await refGenre.push().set(genreC.text);
    genreC.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Text('VJ Names', style: TextStyle(color: Colors.white70)),
        Row(
          children: [
            Expanded(child: TextField(controller: vjC, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'New VJ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
            IconButton(onPressed: addVj, icon: Icon(Icons.add, color: kBlue))
          ],
        ),
        StreamBuilder(
          stream: refVj.onValue,
          builder: (c, snap) {
            if (!snap.hasData || snap.data!.snapshot.value == null) return Text('No VJs', style: TextStyle(color: Colors.white54));
            final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
            final list = map.entries.toList();
            return Wrap(spacing: 6, children: list.map((e) => Chip(label: Text(e.value.toString(), style: TextStyle(fontSize: 10)), onDeleted: () async {
              await refVj.child(e.key).remove();
            })).toList());
          },
        ),
        SizedBox(height: 16),
        Text('Genres', style: TextStyle(color: Colors.white70)),
        Row(
          children: [
            Expanded(child: TextField(controller: genreC, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'New Genre', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
            IconButton(onPressed: addGenre, icon: Icon(Icons.add, color: kBlue))
          ],
        ),
        StreamBuilder(
          stream: refGenre.onValue,
          builder: (c, snap) {
            if (!snap.hasData || snap.data!.snapshot.value == null) return Text('No Genres', style: TextStyle(color: Colors.white54));
            final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
            final list = map.entries.toList();
            return Wrap(spacing: 6, children: list.map((e) => Chip(label: Text(e.value.toString(), style: TextStyle(fontSize: 10)), onDeleted: () async {
              await refGenre.child(e.key).remove();
            })).toList());
          },
        ),
      ],
    );
  }
}
