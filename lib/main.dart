import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'dart:typed_data';

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
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode mode = ThemeMode.dark;
  @override
  void initState(){super.initState(); _loadTheme();}
  Future<void> _loadTheme() async {final p=await SharedPreferences.getInstance(); final isDark=p.getBool('isDark')??true; setState(()=>mode=isDark?ThemeMode.dark:ThemeMode.light);}
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      themeMode:mode,
      theme:ThemeData.light(),
      darkTheme:ThemeData.dark().copyWith(scaffoldBackgroundColor:const Color(0xFF020617)),
      home:MainNav(onTheme:(isDark) async {final p=await SharedPreferences.getInstance(); await p.setBool('isDark',isDark); setState(()=>mode=isDark?ThemeMode.dark:ThemeMode.light);}),
    );
  }
}

class MainNav extends StatefulWidget {
  final Function(bool) onTheme;
  const MainNav({super.key, required this.onTheme});
  @override
  State<MainNav> createState()=>_MainNavState();
}
class _MainNavState extends State<MainNav>{
  int idx=0;
  late List<Widget> pages;
  @override
  void initState(){super.initState(); pages=[const HomeTab(), const SearchTab(), const DownloadsTab(), const DashboardTab(), ProfileTab(onTheme:widget.onTheme)];}
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body:pages[idx],
      bottomNavigationBar:BottomNavigationBar(
        currentIndex:idx, type:BottomNavigationBarType.fixed, backgroundColor:const Color(0xFF0F172A), selectedItemColor:const Color(0xFF38BDF8), unselectedItemColor:Colors.white54,
        onTap:(i)=>setState(()=>idx=i),
        items:const [
          BottomNavigationBarItem(icon:Icon(Icons.home_rounded), label:"Home"),
          BottomNavigationBarItem(icon:Icon(Icons.search_rounded), label:"Search"),
          BottomNavigationBarItem(icon:Icon(Icons.download_rounded), label:"Downloads"),
          BottomNavigationBarItem(icon:Icon(Icons.bar_chart_rounded), label:"Dashboard"),
          BottomNavigationBarItem(icon:Icon(Icons.person_rounded), label:"Profile"),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {const HomeTab({super.key}); @override State<HomeTab> createState()=>_HomeTabState();}
class _HomeTabState extends State<HomeTab>{
  final ref=FirebaseDatabase.instance.ref('movies');
  String q="";
  @override
  Widget build(BuildContext context){
    return SafeArea(child:Column(children:[
      Padding(padding:const EdgeInsets.all(12), child:TextField(onChanged:(v)=>setState(()=>q=v.toLowerCase()), decoration:InputDecoration(hintText:"Search Movies / Series...", prefixIcon:const Icon(Icons.search), filled:true, fillColor:const Color(0xFF1E293B), border:OutlineInputBorder(borderRadius:BorderRadius.circular(12), borderSide:BorderSide.none)))),
      Expanded(child:StreamBuilder(stream:ref.onValue, builder:(c,snap){
        if(!snap.hasData || snap.data!.snapshot.value==null) return const Center(child:CircularProgressIndicator());
        final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
        final list=map.entries.where((e){final m=Map<String,dynamic>.from(e.value as Map); return (m['title']??'').toString().toLowerCase().contains(q);}).toList();
        if(list.isEmpty) return const Center(child:Text("No Movies Found", style:TextStyle(color:Colors.white54)));
        return GridView.builder(padding:const EdgeInsets.all(8), gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.65, crossAxisSpacing:8, mainAxisSpacing:8), itemCount:list.length, itemBuilder:(c,i){final m=Map<String,dynamic>.from(list[i].value as Map); return MovieCard(data:m, id:list[i].key);});
      })),
    ]));
  }
}

class MovieCard extends StatelessWidget {
  final Map<String,dynamic> data; final String id;
  const MovieCard({super.key, required this.data, required this.id});
  @override
  Widget build(BuildContext context){
    final poster=data['posterBase64']??'';
    return GestureDetector(onTap:()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>DetailPage(data:data, id:id))), child:Container(decoration:BoxDecoration(color:const Color(0xFF1E293B), borderRadius:BorderRadius.circular(12)), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
