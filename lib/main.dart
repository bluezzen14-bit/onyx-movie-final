import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

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
      appId: "1:243702982500:web:a65b9c59dd2e06c3ec7c71"
    )
  );
  runApp(MyApp());
}

class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  const LiquidGlass({super.key, required this.child, this.radius=20});
  @override Widget build(BuildContext context){
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
          ),
          child: child,
        ),
      ),
    );
  }
}

class IPhoneLoader extends StatefulWidget {
  final double size;
  final String? text;
  const IPhoneLoader({super.key, this.size=20, this.text});
  @override State<IPhoneLoader> createState()=>_IPhoneLoaderState();
}
class _IPhoneLoaderState extends State<IPhoneLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override void initState(){super.initState(); _controller=AnimationController(vsync:this, duration: Duration(milliseconds: 800))..repeat();}
  @override void dispose(){_controller.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        RotationTransition(
          turns: _controller,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _IOSSpinnerPainter(color: Colors.white.withOpacity(0.5))
          )
        ),
        if(widget.text!=null)
          Padding(
            padding: EdgeInsets.only(top:10),
            child: Text(widget.text!, style: TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center)
          ),
      ]),
    );
  }
}
class _IOSSpinnerPainter extends CustomPainter {
  final Color color; _IOSSpinnerPainter({required this.color});
  @override void paint(Canvas canvas, Size size){
    final paint=Paint()..strokeCap=StrokeCap.round..strokeWidth=size.width*0.12;
    final center=Offset(size.width/2, size.height/2);
    final radius=size.width*0.45;
    final innerRadius=size.width*0.22;
    for(int i=0;i<12;i++){
      final angle = (i * 30) * 3.1415926535 / 180;
      final opacity = 0.2 + (i / 12) * 0.8;
      paint.color=color.withOpacity(opacity*0.8);
      final x1=center.dx + innerRadius * math.cos(angle);
      final y1=center.dy + innerRadius * math.sin(angle);
      final x2=center.dx + radius * math.cos(angle);
      final y2=center.dy + radius * math.sin(angle);
      canvas.drawLine(Offset(x1,y1), Offset(x2,y2), paint);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}

class MyApp extends StatefulWidget{const MyApp({super.key});@override State<MyApp> createState()=>MyAppState();}
class MyAppState extends State<MyApp>{
  ThemeMode mode=ThemeMode.dark;
  @override void initState(){super.initState();loadTheme();}
  loadTheme() async {final p=await SharedPreferences.getInstance();setState(()=>mode=(p.getBool('isDark')??true)?ThemeMode.dark:ThemeMode.light);}
  @override Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      themeMode:mode,
      home:AuthScreen(onTheme:(isDark) async {
        final p=await SharedPreferences.getInstance();
        await p.setBool('isDark',isDark);
        setState(()=>mode=isDark?ThemeMode.dark:ThemeMode.light);
      })
    );
  }
}

class AuthScreen extends StatefulWidget{final Function(bool) onTheme;const AuthScreen({super.key,required this.onTheme});@override State<AuthScreen> createState()=>AuthScreenState();}
class AuthScreenState extends State<AuthScreen>{
  final emailC=TextEditingController();final passC=TextEditingController();bool loading=false;
  final Map<String,String> admins={"mugabibenjamin14@gmail.com":"Mugabibe+-@1","rachetyaz900@gmail.com":"Akram2007"};
  void doAuth() async {
    final e=emailC.text.trim();final p=passC.text;
    if(e.isEmpty||p.isEmpty)return;
    setState(()=>loading=true);
    final pref=await SharedPreferences.getInstance();
    final isAdminMail=admins.containsKey(e);
    if(isAdminMail&&admins[e]!=p){
      setState(()=>loading=false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrong admin password")));
      return;
    }
    await pref.setString('user_email',e);
    await pref.setBool('is_admin',isAdminMail);
    await pref.setString('registered_email_permanent', e);
    setState(()=>loading=false);
    if(!mounted)return;
    if(isAdminMail){
      Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>StartSelector(onTheme:widget.onTheme,email:e)));
    } else {
      Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>UserMainNav(onTheme:widget.onTheme,email:e,isAdmin:false)));
    }
  }
  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:Color(0xFF020617),
      body:SafeArea(
        child:Padding(
          padding:EdgeInsets.all(20),
          child:Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children:[
              Icon(Icons.movie_filter,color:Color(0xFF38BDF8),size:70),
              Text("ONYX MOVIES",style:TextStyle(color:Colors.white,fontSize:26,fontWeight:FontWeight.bold)),
              SizedBox(height:20),
              LiquidGlass(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal:12),
                  child: TextField(controller:emailC,style:TextStyle(color:Colors.white),decoration:InputDecoration(labelText:"Email",border:InputBorder.none))
                )
              ),
              SizedBox(height:10),
              LiquidGlass(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal:12),
                  child: TextField(controller:passC,obscureText:true,style:TextStyle(color:Colors.white),decoration:InputDecoration(labelText:"Password",border:InputBorder.none))
                )
              ),
              SizedBox(height:20),
              SizedBox(
                width:double.infinity,
                height:50,
                child:ElevatedButton(
                  onPressed:loading?null:doAuth,
                  style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF38BDF8)),
                  child:loading?IPhoneLoader(size:18):Text("REGISTER / LOGIN",style:TextStyle(color:Colors.black,fontWeight:FontWeight.bold))
                )
              )
            ]
          )
        )
      )
    );
  }
}

class StartSelector extends StatelessWidget{
  final Function(bool) onTheme;final String email;
  const StartSelector({super.key,required this.onTheme,required this.email});
  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:Color(0xFF020617),
      body:Center(
        child:Padding(
          padding:EdgeInsets.all(20),
          child:Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children:[
              Text("Admin: $email",style:TextStyle(color:Colors.orange)),
              SizedBox(height:20),
              GestureDetector(
                onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>UserMainNav(onTheme:onTheme,email:email,isAdmin:true))),
                child:LiquidGlass(
                  radius:20,
                  child: Container(
                    height:120,
                    child:Center(child:Text("USER PANEL\nTransparent Glass iOS 26",textAlign:TextAlign.center,style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)))
                  )
                )
              ),
              SizedBox(height:16),
              GestureDetector(
                onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AdminMainNav(email:email))),
                child:LiquidGlass(
                  radius:20,
                  child: Container(
                    height:120,
                    child:Center(child:Text("ADMIN PANEL\nTransparent PRO",textAlign:TextAlign.center,style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)))
                  )
                )
              )
            ]
          )
        )
      )
    );
  }
}

class UserMainNav extends StatefulWidget{final Function(bool) onTheme;final String email;final bool isAdmin;const UserMainNav({super.key,required this.onTheme,required this.email,required this.isAdmin});@override State<UserMainNav> createState()=>UserMainNavState();}
class UserMainNavState extends State<UserMainNav>{
  int idx=0;
  @override Widget build(BuildContext context){
    final pages=[
      HomeTab(),
      MoviesTab(),
      SeriesTab(),
      DownloadsTab(),
      ProfileTab(onTheme:widget.onTheme,email:widget.email,isAdmin:widget.isAdmin)
    ];
    return Scaffold(
      backgroundColor:Color(0xFF020617),
      body:pages[idx],
      bottomNavigationBar:BottomNavigationBar(
        currentIndex:idx,
        type:BottomNavigationBarType.fixed,
        backgroundColor:Color(0xFF0F172A),
        selectedItemColor:Color(0xFF38BDF8),
        unselectedItemColor:Colors.white54,
        onTap:(i)=>setState(()=>idx=i),
        items:[
          BottomNavigationBarItem(icon:Icon(Icons.home),label:"Home"),
          BottomNavigationBarItem(icon:Icon(Icons.movie),label:"Movies"),
          BottomNavigationBarItem(icon:Icon(Icons.tv),label:"Series"),
          BottomNavigationBarItem(icon:Icon(Icons.download),label:"Downloads"),
          BottomNavigationBarItem(icon:Icon(Icons.person),label:"Profile")
        ]
      )
    );
  }
}

class HomeTab extends StatefulWidget{const HomeTab({super.key});@override State<HomeTab> createState()=>HomeTabState();}
class HomeTabState extends State<HomeTab>{
  final ref=FirebaseDatabase.instance.ref('movies');
  String selectedCategory="";String selectedVJ="";String selectedGenre="";
  List<String> allCategories=["Movie","Series","Animation","Indian","Trending"];
  int bannerIndex=0;List<String> favourites=[];
  @override void initState(){super.initState();loadFavs();}
  loadFavs() async {final p=await SharedPreferences.getInstance();setState(()=>favourites=p.getStringList('favourites')??[]);}
  void showSearchSheet(List<MapEntry> allMovies){
    Set<String> vjSet={};Set<String> genreSet={};
    for(var e in allMovies){
      final m=Map<String,dynamic>.from(e.value as Map);
      if(m['vj']!=null) vjSet.add(m['vj'].toString());
      if(m['genre']!=null) genreSet.add(m['genre'].toString());
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_){
        return StatefulBuilder(builder: (ctx, setS){
          return Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width:40,height:4,decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                  SizedBox(height:16),
                  Text("Search Categories - VJ, Genre", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height:12),Text("VJs (Uploaded in Admin)", style: TextStyle(color: Colors.white54)),
                  Wrap(spacing:8, children: vjSet.map((vj)=>ChoiceChip(label: Text(vj), selected: selectedVJ==vj, onSelected: (v){setState(()=>selectedVJ=v?vj:""); setS(()=>{});} )).toList()),
                  SizedBox(height:12),Text("Genres", style: TextStyle(color: Colors.white54)),
                  Wrap(spacing:8, children: genreSet.map((g)=>ChoiceChip(label: Text(g), selected: selectedGenre==g, onSelected: (v){setState(()=>selectedGenre=v?g:""); setS(()=>{});} )).toList()),
                  SizedBox(height:12),Text("Categories", style: TextStyle(color: Colors.white54)),
                  Wrap(spacing:8, children: allCategories.map((c)=>ChoiceChip(label: Text(c), selected: selectedCategory==c, onSelected: (v){setState(()=>selectedCategory=v?c:""); setS(()=>{});} )).toList()),
                  SizedBox(height:20),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: (){Navigator.pop(context); setState((){});}, child: Text("Apply Filter - Show Selection"))),
                ]
              )
            )
          );
        });
      }
    );
  }
  Widget sectionHeader(String title, List<MapEntry> list){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal:12, vertical:8),
      child: Row(children: [
        Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Spacer(),
        GestureDetector(
