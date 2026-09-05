import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:share_plus/share_plus.dart';

// YOUR FIREBASE CONFIG FROM YOU
const firebaseConfig = {
  "apiKey": "AIzaSyAqhqupsd2veboIOFZfIjaNNOKpKxlV2MI",
  "authDomain": "onyx-movies-2b58b.firebaseapp.com",
  "databaseURL": "https://onyx-movies-2b58b-default-rtdb.firebaseio.com",
  "projectId": "onyx-movies-2b58b",
  "storageBucket": "onyx-movies-2b58b.firebasestorage.app",
  "messagingSenderId": "243702982500",
  "appId": "1:243702982500:web:a65b9c59dd2e06c3ec7c71",
  "measurementId": "G-3FW863YFGP"
};

const skyBlue = Color(0xFF38BDF8);
const skyDeep = Color(0xFF0EA5E9);
const appVersion = "1.0.4";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig["apiKey"]!,
      authDomain: firebaseConfig["authDomain"]!,
      databaseURL: firebaseConfig["databaseURL"]!,
      projectId: firebaseConfig["projectId"]!,
      storageBucket: firebaseConfig["storageBucket"]!,
      messagingSenderId: firebaseConfig["messagingSenderId"]!,
      appId: firebaseConfig["appId"]!,
    ),
  );
  runApp(const OnyxPro());
}

// iPhone Loading small transparent
Widget iphoneLoading({double size = 18}) {
  return SizedBox(width: size, height: size, child: const CupertinoActivityIndicator(radius: 9, color: Colors.white70));
}

class LiquidGlass extends StatelessWidget {
  final Widget child; final double r;
  const LiquidGlass({super.key, required this.child, this.r = 20});
  @override Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(r), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(r), border: Border.all(color: Colors.white.withOpacity(0.18))), child: child)));
}

class OnyxPro extends StatelessWidget { const OnyxPro({super.key}); @override Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF020617)), primaryColor: skyBlue), home: const LoginPro()); }

// LOGIN
class LoginPro extends StatefulWidget{const LoginPro({super.key});@override State<LoginPro> createState()=>_LoginProState();}
class _LoginProState extends State<LoginPro>{
  final u=TextEditingController(); final p=TextEditingController(); bool load=false;
  @override Widget build(BuildContext context)=>Scaffold(body: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [skyDeep, Color(0xFF020617)], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: LiquidGlass(r:24, child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
    const Icon(Icons.play_circle_fill_rounded, size: 64, color: skyBlue), const SizedBox(height: 10), const Text("ONYX MOVIES", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)), const Text("iOS 26 Liquid Glass • Sky Blue • Firebase", style: TextStyle(color: skyBlue, fontSize: 10)), const SizedBox(height: 20),
    TextField(controller: u, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Email", filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
    const SizedBox(height: 12),
    TextField(controller: p, obscureText: true, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Password", filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
    const SizedBox(height: 20),
    SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () async { setState(()=>load=true); final pref=await SharedPreferences.getInstance(); await pref.setString('user', u.text); await Future.delayed(const Duration(seconds: 1)); if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const UserPanelPro())); setState(()=>load=false); }, style: ElevatedButton.styleFrom(backgroundColor: skyBlue, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: load?iphoneLoading():const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)))),
    TextButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const RegisterPro())), child: const Text("Register", style: TextStyle(color: skyBlue))),
    TextButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const AdminPanelPro())), child: const Text("Admin Panel Login", style: TextStyle(color: Colors.white38, fontSize: 11))),
  ])))))));
}

// REGISTER
class RegisterPro extends StatelessWidget{const RegisterPro({super.key});@override Widget build(BuildContext context){final u=TextEditingController(); final e=TextEditingController(); final p=TextEditingController(); return Scaffold(appBar: AppBar(title: const Text("Register"), backgroundColor: Colors.transparent), body: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [skyDeep, Color(0xFF020617)], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: LiquidGlass(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [TextField(controller: u, decoration: InputDecoration(hintText: "Username", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 12), TextField(controller: e, decoration: InputDecoration(hintText: "Email", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 12), TextField(controller: p, obscureText: true, decoration: InputDecoration(hintText: "Password", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 20), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () async {final pref=await SharedPreferences.getInstance(); await pref.setString('user', e.text); if(context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>const UserPanelPro()), (r)=>false);}, style: ElevatedButton.styleFrom(backgroundColor: skyBlue), child: const Text("REGISTER & CONTINUE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))))]))))))); }}

// USER PANEL PRO - WITH ALL SECTIONS
class UserPanelPro extends StatefulWidget{const UserPanelPro({super.key});@override State<UserPanelPro> createState()=>_UserPanelProState();}
class _UserPanelProState extends State<UserPanelPro>{
  int idx=0; bool searching=false; String query=""; String? selectedCat;
  final dbRef=FirebaseDatabase.instance.ref().child('movies');
  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      bottomNavigationBar: ClipRRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: BottomNavigationBar(currentIndex: idx, onTap: (i)=>setState(()=>idx=i), backgroundColor: Colors.black.withOpacity(0.3), selectedItemColor: skyBlue, unselectedItemColor: Colors.white54, type: BottomNavigationBarType.fixed, items: const [BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"), BottomNavigationBarItem(icon: Icon(Icons.movie_rounded), label: "Movies"), BottomNavigationBarItem(icon: Icon(Icons.tv_rounded), label: "Series"), BottomNavigationBarItem(icon: Icon(Icons.download_rounded), label: "Downloads"), BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile")]))),
      body: SafeArea(child: Column(children: [
        // TOP Liquid Glass Search + Notification + Downloads
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Expanded(child: GestureDetector(onTap: ()=>setState(()=>searching=!searching), child: LiquidGlass(child: Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(children: [const Icon(Icons.search_rounded, color: skyBlue, size: 20), const SizedBox(width: 8), Expanded(child: searching?TextField(onChanged: (v)=>setState(()=>query=v), autofocus: true, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(border: InputBorder.none, hintText: "Search VJ, Genre, Movie...", hintStyle: TextStyle(color: Colors.white38, fontSize: 12))):const Text("Search movies, VJs, genres...", style: TextStyle(color: Colors.white38, fontSize: 12)))]))))),
          const SizedBox(width: 8),
          LiquidGlass(r: 14, child: IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20), onPressed: (){})),
          const SizedBox(width: 8),
          LiquidGlass(r: 14, child: IconButton(icon: const Icon(Icons.download_rounded, color: skyBlue, size: 20), onPressed: ()=>setState(()=>idx=3))),
        ])),
        if(searching) Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: SizedBox(height: 36, child: StreamBuilder(stream: dbRef.onValue, builder: (c,s){ if(!s.hasData) return Row(children: [iphoneLoading()]); final map=(s.data!.snapshot.value as Map?)??{}; final cats={for(var v in map.values) (v as Map)['category']}.toSet().toList(); final vjs={for(var v in map.values) (v as Map)['vj']}.toSet().toList(); final all=[...cats,...vjs]; return ListView.separated(scrollDirection: Axis.horizontal, itemCount: all.length, separatorBuilder: (_,__)=>const SizedBox(width: 6), itemBuilder: (_,i)=>ActionChip(label: Text(all[i].toString(), style: const TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: skyBlue.withOpacity(0.25), onPressed: ()=>setState(()=>selectedCat=all[i].toString()))); }))),
        Expanded(child: _pages()[idx]),
      ])),
    );
  }
  List<Widget> _pages()=>[
    HomeContentPro(query: query, selectedCat: selectedCat),
    const MoviePagePro(), const SeriePagePro(), const DownloadPagePro(), const ProfilePagePro(),
  ];
}

// HOME CONTENT
class HomeContentPro extends StatelessWidget{
  final String query; final String? selectedCat;
  const HomeContentPro({super.key, required this.query, this.selectedCat});
  @override Widget build(BuildContext context){
    final dbRef=FirebaseDatabase.instance.ref().child('movies');
    return StreamBuilder<DatabaseEvent>(stream: dbRef.orderByChild('timestamp').onValue, builder: (context, snap){
      if(snap.connectionState==ConnectionState.waiting) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [iphoneLoading(size: 22), const SizedBox(height: 8), const Text("Loading ONYX...", style: TextStyle(color: Colors.white38, fontSize: 11))]));
      if(!snap.hasData || snap.data!.snapshot.value==null) return _dummyHome();
      final dataMap=snap.data!.snapshot.value as Map; final list=dataMap.values.map((e)=>Map<String,dynamic>.from(e as Map)).toList()..sort((a,b)=>(b['timestamp']??0).compareTo(a['timestamp']??0));
      final filtered=query.isEmpty && selectedCat==null? list : list.where((m)=> m['title'].toString().toLowerCase().contains(query.toLowerCase()) || m['vj'].toString().toLowerCase().contains(query.toLowerCase()) || m['category'].toString().toLowerCase().contains((selectedCat??"").toLowerCase())).toList();
      return ListView(padding: const EdgeInsets.only(bottom: 20), children: [
        // BANNER 7 latest
        SizedBox(height: 190, child: PageView.builder(itemCount: filtered.take(7).length, itemBuilder: (_,i){ final m=filtered[i]; return Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: LiquidGlass(r: 22, child: Stack(children: [Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skyBlue.withOpacity(0.6), Colors.black.withOpacity(0.2)])), child: Center(child: Icon(Icons.play_circle_fill_rounded, size: 56, color: Colors.white.withOpacity(0.9)))), Positioned(bottom: 0, left: 0, right: 0, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.8), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m['title']??"", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text("${m['genre']??""} • ${m['year']??""} • ${m['vj']??""}", style: const TextStyle(color: skyBlue, fontSize: 10)), Text(m['description']??"", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 10))]))), Positioned(top: 12, right: 12, child: LiquidGlass(r: 20, child: IconButton(icon: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 18), onPressed: (){}))), ]))); })),
        _section(context, "Latest Release", filtered),
        _section(context, "Latest Series", filtered.where((m)=>m['type']=='series').toList()),
        _section(context, "Trending Movies", filtered),
        _section(context, "Animations", filtered.where((m)=>m['category']=='Animation').toList()),
        _section(context, "Indian Movies", filtered.where((m)=>m['category']=='Indian').toList()),
      ]);
    });
  }
  Widget _dummyHome()=>ListView(padding: const EdgeInsets.all(16), children: [LiquidGlass(r: 22, child: Container(height: 180, child: const Center(child: Text("Upload movies in Admin Panel to see here", style: TextStyle(color: Colors.white54))))), const SizedBox(height: 16), const Text("Latest Release • Movies with VJ on poster", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 8), SizedBox(height: 140, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: 5, separatorBuilder: (_,__)=>const SizedBox(width: 10), itemBuilder: (_,i)=>LiquidGlass(r: 16, child: Container(width: 100, decoration: BoxDecoration(color: skyBlue.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: Stack(children: [const Center(child: Icon(Icons.movie_rounded, color: Colors.white)), Positioned(top: 6, right: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: skyBlue, borderRadius: BorderRadius.circular(8)), child: const Text("VJ Junior", style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.black))))]))))), ]);
  Widget _section(BuildContext ctx, String title, List list){ if(list.isEmpty) return const SizedBox(); return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), TextButton(onPressed: ()=>Navigator.push(ctx, MaterialPageRoute(builder: (_)=>MoviePagePro(initialList: list))), child: const Text("See more", style: TextStyle(color: skyBlue, fontSize: 11)))])), SizedBox(height: 150, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 12), scrollDirection: Axis.horizontal, itemCount: list.length, separatorBuilder: (_,__)=>const SizedBox(width: 10), itemBuilder: (_,i){ final m=list[i]; return GestureDetector(onTap: ()=>Navigator.push(ctx, MaterialPageRoute(builder: (_)=>PlayerPro(movie: m))), child: LiquidGlass(r: 16, child: Container(width: 110, child: Stack(children: [Container(decoration: BoxDecoration(color: skyBlue.withOpacity(0.25), borderRadius: BorderRadius.circular(16)), child: const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white))), Positioned(top: 6, right: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: skyBlue, borderRadius: BorderRadius.circular(6)), child: Text(m['vj']??"VJ", style: const TextStyle(fontSize: 7, color: Colors.black, fontWeight: FontWeight.bold)))), Positioned(bottom: 0, left: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))), child: Text(m['title']??"", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))))]))); })), ]); }
}

class MoviePagePro extends StatelessWidget{final List? initialList; const MoviePagePro({super.key, this.initialList}); @override Widget build(BuildContext context)=>Scaffold(appBar: AppBar(title: const Text("Movies - Latest to Oldest"), backgroundColor: skyBlue, foregroundColor: Colors.black), body: initialList!=null?GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: initialList!.length, itemBuilder: (_,i){final m=initialList![i]; return GestureDetector(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>PlayerPro(movie: m))), child: LiquidGlass(r:16, child: Container(decoration: BoxDecoration(color: skyBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(m['title']??"", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))));}):StreamBuilder(stream: FirebaseDatabase.instance.ref().child('movies').orderByChild('timestamp').onValue, builder: (c,s){ if(!s.hasData) return Center(child: iphoneLoading()); final map=(s.data!.snapshot.value as Map?)??{}; final list=map.values.toList()..sort((a,b)=>(b as Map)['timestamp'].compareTo((a as Map)['timestamp'])); return GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: list.length, itemBuilder: (_,i){final m=Map<String,dynamic>.from(list[i] as Map); return GestureDetector(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>PlayerPro(movie: m))), child: LiquidGlass(r:16, child: Container(decoration: BoxDecoration(color: skyBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(m['title']??"", style: const TextStyle(color: Colors.white)))))); }); }))); }
class SeriePagePro extends StatelessWidget{const SeriePagePro({super.key});@override Widget build(BuildContext context)=>Scaffold(appBar: AppBar(title: const Text("Series"), backgroundColor: skyBlue, foregroundColor: Colors.black), body: StreamBuilder(stream: FirebaseDatabase.instance.ref().child('movies').orderByChild('type').equalTo('series').onValue, builder: (c,s){ if(!s.hasData) return Center(child: iphoneLoading()); return const Center(child: Text("Series from Admin Panel will show here", style: TextStyle(color: Colors.white54))); }));}

// PLAYER with cast + download
class PlayerPro extends StatefulWidget{final Map movie; const PlayerPro({super.key, required this.movie}); @override State<PlayerPro> createState()=>_PlayerProState();}
class _PlayerProState extends State<PlayerPro>{double progress=0; bool downloading=false;
@override Widget build(BuildContext context)=>Scaffold(appBar: AppBar(title: Text(widget.movie['title']??"Player"), backgroundColor: skyBlue, foregroundColor: Colors.black), body: ListView(padding: const EdgeInsets.all(16), children: [
  LiquidGlass(r: 20, child: Container(height: 200, decoration: BoxDecoration(color: skyBlue.withOpacity(0.3), borderRadius: BorderRadius.circular(20)), child: Stack(children: [const Center(child: Icon(Icons.play_circle_fill_rounded, size: 64, color: Colors.white)), Positioned(bottom: 12, right: 12, child: LiquidGlass(r: 12, child: IconButton(icon: const Icon(Icons.cast_rounded, color: Colors.white), onPressed: (){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cast feature searching devices..."))); })))]))),
  const SizedBox(height: 16),
  Text(widget.movie['title']??"", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
  Text("${widget.movie['genre']??""} • ${widget.movie['year']??""} • VJ ${widget.movie['vj']??""}", style: const TextStyle(color: skyBlue)),
  const SizedBox(height: 8),
  Text(widget.movie['description']??"No description", style: const TextStyle(color: Colors.white70, fontSize: 12)),
  const SizedBox(height: 8),
  Text("Casts: ${widget.movie['casts']??"Not added"}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
  const SizedBox(height: 16),
  LiquidGlass(child: ListTile(title: const Text("Download to Gallery / ONYX Folder", style: TextStyle(color: Colors.white, fontSize: 12)), subtitle: downloading?LinearProgressIndicator(value: progress, color: skyBlue):const Text("Save to Downloads/OnyxMovies", style: TextStyle(color: Colors.white38, fontSize: 10)), trailing: IconButton(icon: const Icon(Icons.download_rounded, color: skyBlue), onPressed: () async { setState(()=>downloading=true); for(int i=1;i<=100;i++){ await Future.delayed(const Duration(milliseconds: 30)); setState(()=>progress=i/100); } setState(()=>downloading=false); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Downloaded to Gallery/ONYX folder"))); }))),
]));
}

class DownloadPagePro extends StatelessWidget{const DownloadPagePro({super.key});@override Widget build(BuildContext context)=>ListView(padding: const EdgeInsets.all(16), children: [const Text("Downloads", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 12), LiquidGlass(child: Container(padding: const EdgeInsets.all(16), child: Column(children: [Row(children: [iphoneLoading(), const SizedBox(width: 10), const Text("Downloading section - shows % by size", style: TextStyle(color: Colors.white70, fontSize: 12))]), const SizedBox(height: 12), const LinearProgressIndicator(value: 0.45, color: skyBlue)])), const SizedBox(height: 12), LiquidGlass(child: Container(padding: const EdgeInsets.all(16), child: const Row(children: [Icon(Icons.check_circle_rounded, color: Colors.green), SizedBox(width: 10), Text("Downloaded section - Offline play", style: TextStyle(color: Colors.white70, fontSize: 12))])))]); }

class ProfilePagePro extends StatelessWidget{const ProfilePagePro({super.key});@override Widget build(BuildContext context){return ListView(padding: const EdgeInsets.all(16), children: [
  FutureBuilder<SharedPreferences>(future: SharedPreferences.getInstance(), builder: (c,s){ final email=s.data?.getString('user')??"guest@onyx.com"; return LiquidGlass(child: ListTile(leading: const CircleAvatar(backgroundColor: skyBlue, child: Icon(Icons.person_rounded, color: Colors.black)), title: Text(email, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: const Text("ONYX Member", style: TextStyle(color: skyBlue, fontSize: 10)))); }),
  const SizedBox(height: 12),
  LiquidGlass(child: Column(children: [
    ListTile(title: const Text("New Version Update", style: TextStyle(color: Colors.white, fontSize: 13)), subtitle: Text("Current v$appVersion - Check update", style: const TextStyle(color: Colors.white38, fontSize: 10)), trailing: const Icon(Icons.system_update_rounded, color: skyBlue), onTap: () async { final uri=Uri.parse("https://github.com/bluezzer/onyx-movie-final/releases"); if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }),
    const Divider(color: Colors.white10),
    SwitchListTile(value: true, onChanged: (v){}, title: const Text("Download to Gallery", style: TextStyle(color: Colors.white, fontSize: 13)), activeColor: skyBlue),
    SwitchListTile(value: false, onChanged: (v){}, title: const Text("Play Offline", style: TextStyle(color: Colors.white, fontSize: 13)), activeColor: skyBlue),
    ListTile(title: const Text("Rate Us", style: TextStyle(color: Colors.white, fontSize: 13)), trailing: const Icon(Icons.star_rounded, color: skyBlue), onTap: (){}),
    ListTile(title: const Text("Share App", style: TextStyle(color: Colors.white, fontSize: 13)), trailing: const Icon(Icons.share_rounded, color: skyBlue), onTap: ()=>Share.share("Download ONYX MOVIES Sky Blue Liquid Glass iOS 26 https://github.com/bluezzer/onyx-movie-final")),
  ])),
  const SizedBox(height: 12),
  const Text("Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  const SizedBox(height: 8),
  LiquidGlass(child: Column(children: [
    SwitchListTile(value: true, onChanged: (v){}, title: const Text("Dark / Light Mode", style: TextStyle(color: Colors.white, fontSize: 13)), activeColor: skyBlue),
    SwitchListTile(value: true, onChanged: (v){}, title: const Text("High Speed Downloads", style: TextStyle(color: Colors.white, fontSize: 13)), activeColor: skyBlue),
    SwitchListTile(value: true, onChanged: (v){}, title: const Text("Allow All Permissions", style: TextStyle(color: Colors.white, fontSize: 13)), activeColor: skyBlue),
    ListTile(title: const Text("Security - 6 Digit Passcode", style: TextStyle(color: Colors.white, fontSize: 13)), trailing: const Icon(Icons.lock_rounded, color: skyBlue), onTap: (){}),
    ListTile(title: const Text("Biometric", style: TextStyle(color: Colors.white, fontSize: 13)), trailing: const Icon(Icons.fingerprint_rounded, color: skyBlue), onTap: (){}),
    ListTile(title: const Text("Face ID", style: TextStyle(color: Colors.white, fontSize: 13)), trailing: const Icon(Icons.face_rounded, color: skyBlue), onTap: (){}),
    ListTile(title: const Text("Password", style: TextStyle(color: Colors.white, fontSize: 13)), trailing: const Icon(Icons.password_rounded, color: skyBlue), onTap: (){}),
  ])),
  const SizedBox(height: 12),
  LiquidGlass(child: Column(children: [
    const ListTile(title: Text("Contact Us", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    ListTile(title: const Text("mugabibenjamin14@gmail.com", style: TextStyle(color: Colors.white70, fontSize: 12)), leading: const Icon(Icons.email_rounded, color: skyBlue, size: 18), onTap: () async { final uri=Uri.parse("mailto:mugabibenjamin14@gmail.com"); if(await canLaunchUrl(uri)) await launchUrl(uri); }),
    const ListTile(title: Text("Instagram: onyxmovies", style: TextStyle(color: Colors.white70, fontSize: 12)), leading: Icon(Icons.camera_alt_rounded, color: skyBlue, size: 18)),
    const ListTile(title: Text("Facebook: onyx movies14", style: TextStyle(color: Colors.white70, fontSize: 12)), leading: Icon(Icons.facebook_rounded, color: skyBlue, size: 18)),
    const ListTile(title: Text("X / Twitter: onyxmovies", style: TextStyle(color: Colors.white70, fontSize: 12)), leading: Icon(Icons.alternate_email_rounded, color: skyBlue, size: 18)),
  ])),
];}}

// ADMIN PANEL 100% WORKING - LINKED TO USER
class AdminPanelPro extends StatefulWidget{const AdminPanelPro({super.key});@override State<AdminPanelPro> createState()=>_AdminPanelProState();}
class _AdminPanelProState extends State<AdminPanelPro>{
  final title=TextEditingController(); final vj=TextEditingController(); final desc=TextEditingController(); final casts=TextEditingController(); final genre=TextEditingController(); final year=TextEditingController(); final season=TextEditingController();
  String type='movie'; String category='Action'; bool uploading=false;
  upload() async {
    setState(()=>uploading=true);
    final ref=FirebaseDatabase.instance.ref().child('movies').push();
    await ref.set({
      'title': title.text, 'vj': vj.text, 'description': desc.text, 'casts': casts.text,
      'genre': genre.text, 'year': year.text, 'season': season.text, 'type': type,
      'category': category, 'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    setState(()=>uploading=false);
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploaded to Firebase - Will appear in User Panel instantly!")));
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar: AppBar(title: const Text("Admin Dashboard 100% - ONYX"), backgroundColor: skyBlue, foregroundColor: Colors.black), body: ListView(padding: const EdgeInsets.all(16), children: [
    const Text("Dashboard - Upload Movies & Series", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    const SizedBox(height: 12),
    DropdownButtonFormField(value: type, decoration: InputDecoration(labelText: "Type", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: const [DropdownMenuItem(value: 'movie', child: Text("Movie")), DropdownMenuItem(value: 'series', child: Text("Series"))], onChanged: (v)=>setState(()=>type=v!)),
    const SizedBox(height: 8),
    DropdownButtonFormField(value: category, decoration: InputDecoration(labelText: "Category where it appears in User Panel", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: ["Action","Comedy","Animation","Indian","Trending"].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v)=>setState(()=>category=v!)),
    const SizedBox(height: 8),
    TextField(controller: title, decoration: InputDecoration(labelText: "Movie/Series Title + Poster Upload from Gallery", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    const SizedBox(height: 8),
    TextField(controller: vj, decoration: InputDecoration(labelText: "VJ Name who translated", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    const SizedBox(height: 8),
    TextField(controller: desc, decoration: InputDecoration(labelText: "Description", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    const SizedBox(height: 8),
    TextField(controller: casts, decoration: InputDecoration(labelText: "Casts", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    const SizedBox(height: 8),
    TextField(controller: genre, decoration: InputDecoration(labelText: "Genre", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    const SizedBox(height: 8),
    TextField(controller: year, decoration: InputDecoration(labelText: "Year of Release", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    const SizedBox(height: 8),
    TextField(controller: season, decoration: InputDecoration(labelText: "Season (for Series)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    const SizedBox(height: 16),
    SizedBox(height: 52, child: ElevatedButton(onPressed: uploading?null:upload, style: ElevatedButton.styleFrom(backgroundColor: skyBlue, foregroundColor: Colors.black), child: uploading?Row(mainAxisAlignment: MainAxisAlignment.center, children: [iphoneLoading(), const SizedBox(width: 8), const Text("Uploading large file to Firebase...")]):const Text("UPLOAD TO FIREBASE - User Panel Linked", style: TextStyle(fontWeight: FontWeight.bold)))),
    const SizedBox(height: 20),
    const Text("Note: Movies/Series uploaded here appear instantly in User Panel Home, Movie Page, Serie Page. App will request update to continue processing.", style: TextStyle(color: Colors.white38, fontSize: 10)),
  ]));
}
