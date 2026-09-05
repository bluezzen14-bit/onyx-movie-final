import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const OnyxMoviesApp());

const String currentAppVersion = "1.0.3";
const String latestVersionUrl = "https://raw.githubusercontent.com/bluezzer/onyx-movie-final/main/version.json";
const String apkDownloadUrl = "https://github.com/bluezzer/onyx-movie-final/releases/latest/download/app-release.apk";

class MovieModel {
  final String title; final String category; final String vjName; final String videoUrl;
  final Color color;
  MovieModel({required this.title, required this.category, required this.vjName, required this.videoUrl, required this.color});
}

List<MovieModel> allMovies = [
  MovieModel(title: "John Wick 4", category: "Action", vjName: "VJ Junior", videoUrl: "https://test-videos.co.uk/vids/sintel/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4", color: Colors.red),
  MovieModel(title: "Lwasa", category: "Comedy", vjName: "VJ Jingo", videoUrl: "https://test-videos.co.uk/vids/sintel/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4", color: Colors.blue),
  MovieModel(title: "The Black Panther", category: "Action", vjName: "VJ Emmy", videoUrl: "https://test-videos.co.uk/vids/sintel/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4", color: Colors.green),
];

class OnyxMoviesApp extends StatelessWidget {
  const OnyxMoviesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'ONYX MOVIES', debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const LoginScreen());
  }
}

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState() => _LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController(); final _pass = TextEditingController(); bool _isLoading = false;
  void _login() async {
    setState(()=>_isLoading=true); await Future.delayed(const Duration(seconds: 2));
    if(_user.text=="admin" && _pass.text=="admin123"){ if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const AdminPanel())); }
    else if(_user.text.isNotEmpty){
      final prefs = await SharedPreferences.getInstance(); await prefs.setString('user', _user.text);
      if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomeScreen()));
    } else { if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter username"))); }
    setState(()=>_isLoading=false);
  }
  @override Widget build(BuildContext context){
    return Scaffold(body: Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F0F0F), Color(0xFF1A1A2E)], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: Center(child: SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.play_circle_fill_rounded, size: 80, color: Color(0xFFF9C27F)), const SizedBox(height: 16),
      const Text("ONYX MOVIES", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)), const Text("v$currentAppVersion", style: TextStyle(color: Colors.white54)), const SizedBox(height: 32),
      TextField(controller: _user, decoration: InputDecoration(labelText: "Username", filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 16),
      TextField(controller: _pass, obscureText: true, decoration: InputDecoration(labelText: "Password", filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 24),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading?null:_login, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF9C27F), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _isLoading?const SizedBox(width:22,height:22,child:CircularProgressIndicator(strokeWidth:2)):const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)))),
    ])))));
  }
}

Widget iphoneLoading({double size=22}){ return SizedBox(width: size, height: size, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFF9C27F))); }

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  String searchQuery=""; String selectedVJ="All"; bool isLoadingMovies=false;
  List<String> get vjList => ["All",...{for(var m in allMovies) m.vjName}];
  @override void initState(){ super.initState(); _loadMovies(); }
  void _loadMovies() async { setState(()=>isLoadingMovies=true); await Future.delayed(const Duration(seconds: 1)); setState(()=>isLoadingMovies=false); }
  @override Widget build(BuildContext context){
    final filtered = allMovies.where((m){ final q=searchQuery.toLowerCase(); return (m.title.toLowerCase().contains(q) || m.vjName.toLowerCase().contains(q)) && (selectedVJ=="All" || m.vjName==selectedVJ); }).toList();
    return Scaffold(appBar: AppBar(title: const Text('ONYX MOVIES v$currentAppVersion'), backgroundColor: const Color(0xFFF9C27F), foregroundColor: Colors.black, actions: [IconButton(onPressed: () async { final uri=Uri.parse(apkDownloadUrl); if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }, icon: const Icon(Icons.system_update))]), body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(onChanged: (v)=>setState(()=>searchQuery=v), decoration: InputDecoration(hintText: "Search movie or VJ...", prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: DropdownButtonFormField<String>(value: selectedVJ, decoration: InputDecoration(labelText: "Filter by VJ", filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: vjList.map((vj)=>DropdownMenuItem(value: vj, child: Text(vj))).toList(), onChanged: (v)=>setState(()=>selectedVJ=v!))),
      const SizedBox(height: 12),
      Expanded(child: isLoadingMovies?Center(child: iphoneLoading(size: 30)):GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: filtered.length, itemBuilder: (context,i){ final m=filtered[i]; return GestureDetector(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>PlayerScreen(movie: m))), child: Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Stack(children: [Container(decoration: BoxDecoration(color: m.color.withOpacity(0.5), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))), child: Center(child: Icon(Icons.play_circle_fill_rounded, size: 50, color: Colors.white.withOpacity(0.9)))), Positioned(top:8,right:8, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.download_rounded, size:16)))])),
        Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${m.category} • ${m.vjName}', style: const TextStyle(fontSize:10, color: Colors.white54))]))
      ]))); })),
    ]));
  }
}

class PlayerScreen extends StatelessWidget { final MovieModel movie; const PlayerScreen({super.key, required this.movie}); @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text(movie.title)), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.play_circle_fill_rounded, size:100, color: movie.color), const SizedBox(height:20), Text(movie.title, style: const TextStyle(fontSize:22, fontWeight: FontWeight.bold)), Text("Translated by ${movie.vjName}"), const SizedBox(height:20), ElevatedButton(onPressed: () async { final uri=Uri.parse(movie.videoUrl); if(await canLaunchUrl(uri)) await launchUrl(uri); }, child: const Text("Play Video"))]))); } }

class AdminPanel extends StatelessWidget { const AdminPanel({super.key}); @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('ADMIN v$currentAppVersion'), backgroundColor: const Color(0xFFF9C27F)), body: ListView(padding: const EdgeInsets.all(16), children: [const Text("Admin Panel - ONYX MOVIES", style: TextStyle(fontSize:18, fontWeight: FontWeight.bold)), const SizedBox(height:20),...allMovies.map((m)=>ListTile(title: Text(m.title), subtitle: Text(m.vjName), leading: CircleAvatar(backgroundColor: m.color, child: const Icon(Icons.movie))))])); } }
