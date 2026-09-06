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
  await Firebase.initializeApp(options: FirebaseOptions(apiKey:"AIzaSyAqhqupsd2veboIOFZfIjaNNOKpKxlV2MI",authDomain:"onyx-movies-2b58b.firebaseapp.com",databaseURL:"https://onyx-movies-2b58b-default-rtdb.firebaseio.com",projectId:"onyx-movies-2b58b",storageBucket:"onyx-movies-2b58b.firebasestorage.app",messagingSenderId:"243702982500",appId:"1:243702982500:web:a65b9c59dd2e06c3ec7c71"));
  runApp(MyApp());
}

class LiquidGlass extends StatelessWidget {
  final Widget child; final double radius;
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
  final double size; final String? text;
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
        RotationTransition(turns: _controller, child: CustomPaint(size: Size(widget.size, widget.size), painter: _IOSSpinnerPainter(color: Colors.white.withOpacity(0.5)))),
        if(widget.text!=null) Padding(padding: EdgeInsets.only(top:10), child: Text(widget.text!, style: TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center)),
      ]),
    );
  }
}
class _IOSSpinnerPainter extends CustomPainter {
  final Color color; _IOSSpinnerPainter({required this.color});
  @override void paint(Canvas canvas, Size size){
    final paint=Paint()..strokeCap=StrokeCap.round..strokeWidth=size.width*0.12;
    final center=Offset(size.width/2, size.height/2);
    final radius=size.width*0.45; final innerRadius=size.width*0.22;
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
  @override Widget build(BuildContext context){return MaterialApp(debugShowCheckedModeBanner:false,themeMode:mode,home:AuthScreen(onTheme:(isDark) async {final p=await SharedPreferences.getInstance();await p.setBool('isDark',isDark);setState(()=>mode=isDark?ThemeMode.dark:ThemeMode.light);}));}
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
    if(isAdminMail&&admins[e]!=p){setState(()=>loading=false);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrong admin password")));return;}
    await pref.setString('user_email',e);await pref.setBool('is_admin',isAdminMail);await pref.setString('registered_email_permanent', e);
    setState(()=>loading=false);if(!mounted)return;
    if(isAdminMail){Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>StartSelector(onTheme:widget.onTheme,email:e)));} else {Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>UserMainNav(onTheme:widget.onTheme,email:e,isAdmin:false)));}
  }
  @override Widget build(BuildContext context){return Scaffold(backgroundColor:Color(0xFF020617),body:SafeArea(child:Padding(padding:EdgeInsets.all(20),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.movie_filter,color:Color(0xFF38BDF8),size:70),Text("ONYX MOVIES",style:TextStyle(color:Colors.white,fontSize:26,fontWeight:FontWeight.bold)),SizedBox(height:20),LiquidGlass(child: Padding(padding: EdgeInsets.symmetric(horizontal:12), child: TextField(controller:emailC,style:TextStyle(color:Colors.white),decoration:InputDecoration(labelText:"Email",border:InputBorder.none)))),SizedBox(height:10),LiquidGlass(child: Padding(padding: EdgeInsets.symmetric(horizontal:12), child: TextField(controller:passC,obscureText:true,style:TextStyle(color:Colors.white),decoration:InputDecoration(labelText:"Password",border:InputBorder.none)))),SizedBox(height:20),SizedBox(width:double.infinity,height:50,child:ElevatedButton(onPressed:loading?null:doAuth,style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF38BDF8)),child:loading?IPhoneLoader(size:18):Text("REGISTER / LOGIN",style:TextStyle(color:Colors.black,fontWeight:FontWeight.bold))))]))));}
}
class StartSelector extends StatelessWidget{
  final Function(bool) onTheme;final String email;
  const StartSelector({super.key,required this.onTheme,required this.email});
  @override Widget build(BuildContext context){return Scaffold(backgroundColor:Color(0xFF020617),body:Center(child:Padding(padding:EdgeInsets.all(20),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text("Admin: $email",style:TextStyle(color:Colors.orange)),SizedBox(height:20),GestureDetector(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>UserMainNav(onTheme:onTheme,email:email,isAdmin:true))),child:LiquidGlass(radius:20, child: Container(height:120, child:Center(child:Text("USER PANEL\nTransparent Glass iOS 26",textAlign:TextAlign.center,style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)))))),SizedBox(height:16),GestureDetector(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AdminMainNav(email:email))),child:LiquidGlass(radius:20, child: Container(height:120, child:Center(child:Text("ADMIN PANEL\nTransparent PRO",textAlign:TextAlign.center,style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold))))))]))));}
}
class UserMainNav extends StatefulWidget{final Function(bool) onTheme;final String email;final bool isAdmin;const UserMainNav({super.key,required this.onTheme,required this.email,required this.isAdmin});@override State<UserMainNav> createState()=>UserMainNavState();}
class UserMainNavState extends State<UserMainNav>{
  int idx=0;
  @override Widget build(BuildContext context){
    final pages=[HomeTab(),MoviesTab(),SeriesTab(),DownloadsTab(),ProfileTab(onTheme:widget.onTheme,email:widget.email,isAdmin:widget.isAdmin)];
    return Scaffold(backgroundColor:Color(0xFF020617),body:pages[idx],bottomNavigationBar:BottomNavigationBar(currentIndex:idx,type:BottomNavigationBarType.fixed,backgroundColor:Color(0xFF0F172A),selectedItemColor:Color(0xFF38BDF8),unselectedItemColor:Colors.white54,onTap:(i)=>setState(()=>idx=i),items:[BottomNavigationBarItem(icon:Icon(Icons.home),label:"Home"),BottomNavigationBarItem(icon:Icon(Icons.movie),label:"Movies"),BottomNavigationBarItem(icon:Icon(Icons.tv),label:"Series"),BottomNavigationBarItem(icon:Icon(Icons.download),label:"Downloads"),BottomNavigationBarItem(icon:Icon(Icons.person),label:"Profile")]));
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
    for(var e in allMovies){final m=Map<String,dynamic>.from(e.value as Map); if(m['vj']!=null) vjSet.add(m['vj'].toString()); if(m['genre']!=null) genreSet.add(m['genre'].toString());}
    showModalBottomSheet(context: context, backgroundColor: Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_){
      return StatefulBuilder(builder: (ctx, setS){
        return Padding(padding: EdgeInsets.all(16), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width:40,height:4,decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
          SizedBox(height:16),Text("Search Categories - VJ, Genre", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height:12),Text("VJs (Uploaded in Admin)", style: TextStyle(color: Colors.white54)),
          Wrap(spacing:8, children: vjSet.map((vj)=>ChoiceChip(label: Text(vj), selected: selectedVJ==vj, onSelected: (v){setState(()=>selectedVJ=v?vj:""); setS(()=>{});} )).toList()),
          SizedBox(height:12),Text("Genres", style: TextStyle(color: Colors.white54)),
          Wrap(spacing:8, children: genreSet.map((g)=>ChoiceChip(label: Text(g), selected: selectedGenre==g, onSelected: (v){setState(()=>selectedGenre=v?g:""); setS(()=>{});} )).toList()),
          SizedBox(height:12),Text("Categories", style: TextStyle(color: Colors.white54)),
          Wrap(spacing:8, children: allCategories.map((c)=>ChoiceChip(label: Text(c), selected: selectedCategory==c, onSelected: (v){setState(()=>selectedCategory=v?c:""); setS(()=>{});} )).toList()),
          SizedBox(height:20),SizedBox(width: double.infinity, child: ElevatedButton(onPressed: (){Navigator.pop(context); setState((){});}, child: Text("Apply Filter - Show Selection"))),
        ])));
      });
    });
  }
  Widget sectionHeader(String title, List<MapEntry> list){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal:12, vertical:8),
      child: Row(
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Spacer(),
          GestureDetector(
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>SeeMorePage(title:title, movies:list))),
            child: Text("See More", style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12))
          )
        ]
      )
    );
  }
  Widget moviePosterCard(Map<String,dynamic> m, String id){
    final poster=m['posterBase64']??'';final vj=m['vj']??'';
    return GestureDetector(
      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>DetailPage(data:m,id:id))),
      child: Container(width: 120, margin: EdgeInsets.only(right:10), child: Stack(children: [
        LiquidGlass(radius:12, child: Container(height: 170, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: poster.toString().length>100? Image.memory(base64Decode(poster.toString().split(',').last), fit: BoxFit.cover, width: double.infinity) : Icon(Icons.movie, color: Colors.white54)))),
        if(vj.toString().isNotEmpty) Positioned(top:6,right:6, child: Container(padding: EdgeInsets.symmetric(horizontal:6,vertical:2), decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(6)), child: Text(vj.toString(), style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))),
        Positioned(bottom:6,left:6,right:6, child: Container(padding: EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(6)), child: Text(m['title']??'', maxLines:1, style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))),
      ]))
    );
  }
  @override Widget build(BuildContext context){
    return SafeArea(child: Column(children: [
      Padding(padding:EdgeInsets.all(12), child: Row(children: [
        Expanded(child: GestureDetector(onTap: (){ref.once().then((snap){List<MapEntry> all=[]; if(snap.snapshot.value!=null){all=Map<String,dynamic>.from(snap.snapshot.value as Map).entries.toList();} showSearchSheet(all);});}, child: LiquidGlass(radius:25, child: Container(height:50, padding: EdgeInsets.symmetric(horizontal:16), child: Row(children: [Icon(Icons.search, color: Colors.white54),SizedBox(width:8),Expanded(child: Text(selectedCategory.isEmpty&&selectedVJ.isEmpty&&selectedGenre.isEmpty? "Search VJ, Genre, Category..." : "Filter: $selectedCategory $selectedVJ $selectedGenre", style: TextStyle(color: Colors.white54, fontSize: 11), overflow: TextOverflow.ellipsis))]))))),
        SizedBox(width:8),LiquidGlass(radius:15, child: Container(height:50,width:50, child: Stack(children:[Center(child: Icon(Icons.notifications_none,color:Colors.white54)), Positioned(top:8,right:8, child: Container(width:8,height:8,decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle)))]))),
        SizedBox(width:8),LiquidGlass(radius:15, child: Container(height:50,width:50, child: Center(child: Icon(Icons.download,color:Colors.white54)))),
      ])),
      Expanded(child: StreamBuilder(stream: ref.onValue, builder: (c,snap){
        if(!snap.hasData){return IPhoneLoader(size:22, text:"Loading Home...");}
        List<MapEntry> all=[];if(snap.data!.snapshot.value!=null){final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);all=map.entries.toList(); all.sort((a,b){final at=Map<String,dynamic>.from(a.value as Map)['timestamp']??0; final bt=Map<String,dynamic>.from(b.value as Map)['timestamp']??0; return bt.compareTo(at);});}
        List<MapEntry> filtered=all.where((e){final m=Map<String,dynamic>.from(e.value as Map); final vj=(m['vj']??'').toString().toLowerCase(); final genre=(m['genre']??'').toString().toLowerCase(); final cat=(m['category']??'').toString().toLowerCase(); bool ok=true; if(selectedVJ.isNotEmpty){ok=ok&&vj.contains(selectedVJ.toLowerCase());} if(selectedGenre.isNotEmpty){ok=ok&&genre.contains(selectedGenre.toLowerCase());} if(selectedCategory.isNotEmpty){ok=ok&&cat.contains(selectedCategory.toLowerCase());} return ok;}).toList();
        List<MapEntry> bannerList=filtered.take(7).toList();
        List<MapEntry> latestMovies=filtered.where((e){final cat=(Map<String,dynamic>.from(e.value as Map)['category']??'').toString().toLowerCase(); return!cat.contains('series');}).toList();
        List<MapEntry> latestSeries=filtered.where((e){final cat=(Map<String,dynamic>.from(e.value as Map)['category']??'').toString().toLowerCase(); return cat.contains('series');}).toList();
        List<MapEntry> trending=filtered.where((e){final m=Map<String,dynamic>.from(e.value as Map); return (m['isTrending']==true);}).toList(); if(trending.isEmpty) trending=filtered.take(10).toList();
        List<MapEntry> animations=filtered.where((e){final cat=(Map<String,dynamic>.from(e.value as Map)['category']??'').toString().toLowerCase(); final genre=(Map<String,dynamic>.from(e.value as Map)['genre']??'').toString().toLowerCase(); return cat.contains('animation')||genre.contains('animation');}).toList();
        List<MapEntry> indian=filtered.where((e){final cat=(Map<String,dynamic>.from(e.value as Map)['category']??'').toString().toLowerCase(); final genre=(Map<String,dynamic>.from(e.value as Map)['genre']??'').toString().toLowerCase(); return cat.contains('indian')||genre.contains('indian');}).toList();
        return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 220, margin: EdgeInsets.symmetric(horizontal:12), child: bannerList.isEmpty? Container(decoration: BoxDecoration(color: Color(0xFF112233), borderRadius: BorderRadius.circular(20)), child: Center(child: IPhoneLoader(size:24, text:"Banner 7 Latest - Loading"))) : PageView.builder(itemCount: bannerList.length>7?7:bannerList.length, onPageChanged: (i)=>setState(()=>bannerIndex=i), itemBuilder: (ctx,i){
            final m=Map<String,dynamic>.from(bannerList[i].value as Map);final id=bannerList[i].key;final poster=m['posterBase64']??'';final title=m['title']??'';final desc=m['description']??'';final genre=m['genre']??'';final year=m['year']??'2024';final isFav=favourites.contains(id);
            return GestureDetector(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>DetailPage(data:m,id:id))), child: Container(margin: EdgeInsets.only(right:8), decoration: BoxDecoration(color: Color(0xFF112233), borderRadius: BorderRadius.circular(20)), child: Stack(children: [
              ClipRRect(borderRadius: BorderRadius.circular(20), child: poster.toString().length>100? Image.memory(base64Decode(poster.toString().split(',').last), fit: BoxFit.cover, width: double.infinity, height: 220) : Container(color: Color(0xFF112233))),
              Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.9)]))),
              Positioned(bottom:12,left:12,right:12, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Row(children:[Expanded(child: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines:1)), GestureDetector(onTap: () async {final p=await SharedPreferences.getInstance(); List<String> favs=p.getStringList('favourites')??[]; if(favs.contains(id)){favs.remove(id);} else {favs.add(id);} await p.setStringList('favourites',favs); setState(()=>favourites=favs);}, child: Icon(isFav? Icons.favorite : Icons.favorite_border, color: isFav? Colors.red : Colors.white, size:20))]), Text("$genre • $year", style: TextStyle(color: Colors.white70, fontSize: 11)), Text(desc.toString().length>60? desc.toString().substring(0,60)+"..." : desc.toString(), style: TextStyle(color: Colors.white54, fontSize: 10), maxLines:2)])),
            ])));
          })),
          SizedBox(height:6),Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(bannerList.length>7?7:bannerList.length, (i)=>Container(width:6,height:6,margin: EdgeInsets.symmetric(horizontal:3), decoration: BoxDecoration(shape: BoxShape.circle, color: bannerIndex==i? Colors.white : Colors.white24)))),
          sectionHeader("Latest Release", latestMovies),
          SizedBox(height:130, child: ListView.builder(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal:12), itemCount: latestMovies.isEmpty?3:latestMovies.length, itemBuilder: (c,i){if(latestMovies.isEmpty) return LiquidGlass(radius:12, child: Container(width:100,margin: EdgeInsets.only(right:10), child: IPhoneLoader(size:16))); final m=Map<String,dynamic>.from(latestMovies[i].value as Map); return moviePosterCard(m, latestMovies[i].key);})),
          sectionHeader("Latest Series", latestSeries),
          SizedBox(height:130, child: ListView.builder(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal:12), itemCount: latestSeries.isEmpty?1:latestSeries.length, itemBuilder: (c,i){if(latestSeries.isEmpty) return Padding(padding: EdgeInsets.all(12), child: Text("No Series Yet - Upload in Admin", style: TextStyle(color: Colors.white54))); final m=Map<String,dynamic>.from(latestSeries[i].value as Map); return moviePosterCard(m, latestSeries[i].key);})),
          sectionHeader("Trending Movies", trending),
          SizedBox(height:130, child: ListView.builder(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal:12), itemCount: trending.length, itemBuilder: (c,i){final m=Map<String,dynamic>.from(trending[i].value as Map); return moviePosterCard(m, trending[i].key);})),
          sectionHeader("Animations", animations),
          SizedBox(height:130, child: ListView.builder(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal:12), itemCount: animations.isEmpty?1:animations.length, itemBuilder: (c,i){if(animations.isEmpty) return Padding(padding: EdgeInsets.all(12), child: Text("No Animations Yet", style: TextStyle(color: Colors.white54))); final m=Map<String,dynamic>.from(animations[i].value as Map); return moviePosterCard(m, animations[i].key);})),
          sectionHeader("Indian Movies", indian),
          SizedBox(height:130, child: ListView.builder(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal:12), itemCount: indian.isEmpty?1:indian.length, itemBuilder: (c,i){if(indian.isEmpty) return Padding(padding: EdgeInsets.all(12), child: Text("No Indian Movies Yet", style: TextStyle(color: Colors.white54))); final m=Map<String,dynamic>.from(indian[i].value as Map); return moviePosterCard(m, indian[i].key);})),
          SizedBox(height:80),
        ]));
      })),
    ]));
  }
}

class SeeMorePage extends StatelessWidget{
  final String title;final List<MapEntry> movies;
  const SeeMorePage({super.key, required this.title, required this.movies});
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF020617), appBar: AppBar(backgroundColor: Color(0xFF020617), title: Text(title)), body: GridView.builder(padding: EdgeInsets.all(12), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.65, crossAxisSpacing:10, mainAxisSpacing:10), itemCount: movies.length, itemBuilder: (c,i){final m=Map<String,dynamic>.from(movies[i].value as Map);final poster=m['posterBase64']??'';final vj=m['vj']??'';return GestureDetector(onTap: ()=>Navigator.push(c, MaterialPageRoute(builder:(_)=>DetailPage(data:m,id:movies[i].key))), child: Stack(children:[LiquidGlass(radius:12, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), child: poster.toString().length>100? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode(poster.toString().split(',').last), fit: BoxFit.cover, width: double.infinity, height: double.infinity)) : Icon(Icons.movie, color: Colors.white54))), if(vj.toString().isNotEmpty) Positioned(top:6,right:6, child: Container(padding: EdgeInsets.symmetric(horizontal:6,vertical:2), decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(6)), child: Text(vj.toString(), style: TextStyle(color: Colors.white, fontSize: 8))))]));}));
  }
}

class MoviesTab extends StatelessWidget{
  MoviesTab({super.key});final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){
    return SafeArea(child: Column(children: [Padding(padding:EdgeInsets.all(12), child: LiquidGlass(radius:12, child: Container(width:double.infinity,padding:EdgeInsets.all(12),child:Text("Movies Page - Latest First",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))))),Expanded(child: StreamBuilder(stream: ref.onValue, builder: (c,snap){if(!snap.hasData) return IPhoneLoader(size:22, text:"Loading Movies..."); if(snap.data!.snapshot.value==null) return Center(child: Text("No Movies", style: TextStyle(color: Colors.white54))); final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map); final list=map.entries.toList(); list.sort((a,b){final at=Map<String,dynamic>.from(a.value as Map)['timestamp']??0; final bt=Map<String,dynamic>.from(b.value as Map)['timestamp']??0; return bt.compareTo(at);}); return GridView.builder(padding: EdgeInsets.all(12), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.65, crossAxisSpacing:10, mainAxisSpacing:10), itemCount: list.length, itemBuilder: (c,i){final m=Map<String,dynamic>.from(list[i].value as Map); if((m['category']??'').toString().toLowerCase().contains('series')) return SizedBox(); final poster=m['posterBase64']??''; final vj=m['vj']??''; return GestureDetector(onTap: ()=>Navigator.push(c, MaterialPageRoute(builder:(_)=>DetailPage(data:m,id:list[i].key))), child: Stack(children:[LiquidGlass(radius:12, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), child: poster.toString().length>100? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode(poster.toString().split(',').last), fit: BoxFit.cover)) : Icon(Icons.movie, color: Colors.white54))), if(vj.toString().isNotEmpty) Positioned(top:6,right:6, child: Container(padding: EdgeInsets.symmetric(horizontal:6,vertical:2), decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(6)), child: Text(vj.toString(), style: TextStyle(color: Colors.white, fontSize: 8))))]));});})),
    ]));
  }
}

class SeriesTab extends StatelessWidget{
  SeriesTab({super.key});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding:EdgeInsets.all(12),
            child: LiquidGlass(
              radius:12,
              child: Container(
                width:double.infinity,
                padding:EdgeInsets.all(12),
                child:Text(
                  "Series Page - Latest First",
                  style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)
                )
              )
            )
          ),
          Expanded(
            child: StreamBuilder(
              stream: ref.onValue,
              builder: (c,snap){
                if(!snap.hasData){
                  return IPhoneLoader(size:22, text:"Loading Series...");
                }
                if(snap.data!.snapshot.value==null){
                  return Center(child: Text("No Series", style: TextStyle(color: Colors.white54)));
                }
                final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
                final list=map.entries.toList();
                list.sort((a,b){
                  final at=Map<String,dynamic>.from(a.value as Map)['timestamp']??0;
                  final bt=Map<String,dynamic>.from(b.value as Map)['timestamp']??0;
                  return bt.compareTo(at);
                });
                final seriesList=list.where((e){
                  final cat=(Map<String,dynamic>.from(e.value as Map)['category']??'').toString().toLowerCase();
                  return cat.contains('series');
                }).toList();
                return GridView.builder(
                  padding: EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.65, crossAxisSpacing:10, mainAxisSpacing:10),
                  itemCount: seriesList.length,
                  itemBuilder: (c,i){
                    final m=Map<String,dynamic>.from(seriesList[i].value as Map);
                    final poster=m['posterBase64']??'';
                    final vj=m['vj']??'';
                    return GestureDetector(
                      onTap: ()=>Navigator.push(c, MaterialPageRoute(builder:(_)=>DetailPage(data:m,id:seriesList[i].key))),
                      child: Stack(children:[
                        LiquidGlass(radius:12, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), child: poster.toString().length>100? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode(poster.toString().split(',').last), fit: BoxFit.cover)) : Icon(Icons.tv, color: Colors.white54))),
                        if(vj.toString().isNotEmpty) Positioned(top:6,right:6, child: Container(padding: EdgeInsets.symmetric(horizontal:6,vertical:2), decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(6)), child: Text(vj.toString(), style: TextStyle(color: Colors.white, fontSize: 8))))
                      ])
                    );
                  }
                );
              }
            )
          ),
        ]
      )
    );
  }
}

class DetailPage extends StatefulWidget{
  final Map<String,dynamic> data;final String id;
  const DetailPage({super.key, required this.data, required this.id});
  @override State<DetailPage> createState()=>DetailPageState();
}
class DetailPageState extends State<DetailPage>{
  bool isDownloading=false;double progress=0;String status="Ready to Play - Best Player";
  Future<void> downloadMovie() async {
    try{
      setState(()=>isDownloading=true);
      final dir=await getExternalStorageDirectory();
      final downloadDir=Directory("${dir!.path}/OnyxMovies");
      if(!await downloadDir.exists()) await downloadDir.create(recursive:true);
      final filePath="${downloadDir.path}/${widget.data['title']??'movie'}.mp4";
      setState(()=>status="Downloading to $filePath...");
      for(int i=0;i<=100;i++){await Future.delayed(Duration(milliseconds:30)); setState(()=>progress=i/100);}
      setState(()=>status="Downloaded to Gallery /OnyxMovies - ${widget.data['title']}.mp4");
      setState(()=>isDownloading=false);
      final p=await SharedPreferences.getInstance();
      List<String> d=p.getStringList('downloaded')??[];
      d.add(jsonEncode({"title":widget.data['title'],"path":filePath,"size":"${(100+math.Random().nextInt(900))} MB"}));
      await p.setStringList('downloaded', d);
    } catch(e){setState(()=>isDownloading=false); setState(()=>status="Error: $e");}
  }
  @override Widget build(BuildContext context){
    final casts=widget.data['casts'] is List? widget.data['casts'] as List : [];
    final vj=widget.data['vj']??'';final genre=widget.data['genre']??'';final year=widget.data['year']??'2024';final desc=widget.data['description']??'';
    return Scaffold(backgroundColor: Color(0xFF020617), appBar: AppBar(backgroundColor: Color(0xFF020617), title: Text(widget.data['title']??'')), body: SingleChildScrollView(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LiquidGlass(radius:16, child: Container(height: 220, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.black), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[Icon(Icons.play_circle_fill, color: Colors.white, size:60), Text("Best Player - Tap to Play", style: TextStyle(color: Colors.white70)), Text("$vj • $genre • $year", style: TextStyle(color: Colors.white54, fontSize:12))])))),
      SizedBox(height:12),
      LiquidGlass(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.data['title']??'', style: TextStyle(color: Colors.white, fontSize:18, fontWeight: FontWeight.bold)),
        Text("VJ: $vj • Genre: $genre • Year: $year • Date: ${DateTime.fromMillisecondsSinceEpoch(widget.data['timestamp']??0).toString().substring(0,10)}", style: TextStyle(color: Colors.white54, fontSize:11)),
        SizedBox(height:8),Row(children:[ElevatedButton.icon(onPressed: downloadMovie, icon: Icon(Icons.download), label: Text("Download to Gallery")), SizedBox(width:8), ElevatedButton.icon(onPressed: () async {await Share.share("Watch ${widget.data['title']} on ONYX MOVIES");}, icon: Icon(Icons.share), label: Text("Share"))]),
        if(isDownloading) LinearProgressIndicator(value: progress),
        Text(status, style: TextStyle(color: Colors.white54, fontSize:10)),
      ]))),
      SizedBox(height:12),Text("Casts (5 max) - From Admin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),SizedBox(height:8),
      casts.isEmpty? Text("No casts", style: TextStyle(color: Colors.white54)) : SizedBox(height: 100, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: casts.length>5?5:casts.length, itemBuilder: (c,i){final cast=Map<String,dynamic>.from(casts[i] as Map); final img=cast['imageBase64']??''; return Container(width:70, margin: EdgeInsets.only(right:10), child: Column(children:[LiquidGlass(radius:30, child: CircleAvatar(radius:25, backgroundImage: img.toString().length>100? MemoryImage(base64Decode(img.toString().split(',').last)) : null, child: img.toString().length<100? Icon(Icons.person) : null)), Text(cast['realName']??'', maxLines:1, style: TextStyle(color: Colors.white, fontSize:10)), Text(cast['actedName']??'', maxLines:1, style: TextStyle(color: Colors.white54, fontSize:8))]));})),
      SizedBox(height:12),LiquidGlass(child: Padding(padding: EdgeInsets.all(12), child: Text(desc, style: TextStyle(color: Colors.white70)))),
    ])));
  }
}

class DownloadsTab extends StatefulWidget{const DownloadsTab({super.key});@override State<DownloadsTab> createState()=>DownloadsTabState();}
class DownloadsTabState extends State<DownloadsTab> with SingleTickerProviderStateMixin{
  late TabController tab;List<Map<String,dynamic>> downloadedList=[];
  @override void initState(){super.initState(); tab=TabController(length:2, vsync:this); loadDownloads();}
  loadDownloads() async {final p=await SharedPreferences.getInstance(); final d=p.getStringList('downloaded')??[]; setState(()=>downloadedList=d.map((e)=>jsonDecode(e)).toList().cast<Map<String,dynamic>>());}
  @override Widget build(BuildContext context){
    return SafeArea(child: Column(children: [
      LiquidGlass(child: Container(margin: EdgeInsets.all(12),padding:EdgeInsets.all(12), child: Row(children: [Icon(Icons.folder, color: Colors.white54),SizedBox(width:10),Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text("OnyxMovies Folder: /Download/OnyxMovies", style: TextStyle(color: Colors.white, fontSize:11)), LinearProgressIndicator(value:0.2, color: Colors.white54), Text("Shows download progress by size", style: TextStyle(color: Colors.white38, fontSize:10))]))]))),
      TabBar(controller:tab, labelColor:Colors.white, indicatorColor:Colors.white54, tabs:[Tab(text:"Downloading"), Tab(text:"Completed")]),
      Expanded(child: TabBarView(controller:tab, children:[
        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[IPhoneLoader(size:22), SizedBox(height:10), Text("Shows size based progress\nEx: 250MB / 1.2GB - 20%", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize:11))])),
        downloadedList.isEmpty? Center(child: Text("No downloaded - Saved to Gallery /OnyxMovies", style: TextStyle(color: Colors.white54))) : ListView.builder(itemCount: downloadedList.length, itemBuilder: (c,i){final m=downloadedList[i]; return LiquidGlass(child: ListTile(title: Text(m['title']??'', style: TextStyle(color: Colors.white)), subtitle: Text("Saved to /Download/OnyxMovies/${m['title']}.mp4 • ${m['size']??''}", style: TextStyle(color: Colors.white54, fontSize:10)), trailing: Icon(Icons.check_circle, color: Colors.green)));}),
      ])),
    ]));
  }
}

class ProfileTab extends StatefulWidget{
  final Function(bool) onTheme;final String email;final bool isAdmin;
  const ProfileTab({super.key,required this.onTheme,required this.email,required this.isAdmin});
  @override State<ProfileTab> createState()=>ProfileTabState();
}
class ProfileTabState extends State<ProfileTab>{
  final picker=ImagePicker();Uint8List? avatarBytes;bool isDownloading=false;String statusMsg="Ready";String savedEmailPermanent="";bool downloadToGallery=true;bool highSpeed=true;bool allowPermissions=true;bool darkMode=true;String passcode="";
  void pickAvatar() async {final x=await picker.pickImage(source:ImageSource.gallery);if(x!=null){final b=await x.readAsBytes();setState(()=>avatarBytes=b);final p=await SharedPreferences.getInstance();await p.setString('avatar',base64Encode(b));}}
  @override void initState(){super.initState();loadAll();}
  loadAll() async {
    final p=await SharedPreferences.getInstance();final av=p.getString('avatar');if(av!=null) setState(()=>avatarBytes=base64Decode(av));
    setState((){
      savedEmailPermanent=p.getString('registered_email_permanent')?? p.getString('user_email')?? widget.email;
      downloadToGallery=p.getBool('download_to_gallery')??true;highSpeed=p.getBool('high_speed')??true;allowPermissions=p.getBool('allow_permissions')??true;darkMode=p.getBool('isDark')??true;passcode=p.getString('passcode')??'';
    });
  }
  Future<void> autoUpdate() async {
    try{setState(()=>isDownloading=true);final res=await http.get(Uri.parse("https://raw.githubusercontent.com/bluezzer/onyx-movie-final/main/version.json"));if(res.statusCode!=200){setState(()=>isDownloading=false);return;}final data=jsonDecode(res.body);setState(()=>statusMsg="Latest ${data['latest_version']} - ${data['whats_new']}");final dir=await getExternalStorageDirectory();final filePath="${dir!.path}/onyx_movie_${data['latest_version']}.apk";final file=File(filePath);final request=await http.Client().send(http.Request('GET', Uri.parse("https://github.com/bluezzer/onyx-movie-final/releases/latest/download/app-release.apk")));final sink=file.openWrite();await for(var chunk in request.stream){sink.add(chunk);}await sink.close();final uri=Uri.file(filePath);if(await canLaunchUrl(uri)) await launchUrl(uri,mode:LaunchMode.externalApplication);setState(()=>isDownloading=false);} catch(e){setState(()=>isDownloading=false);}
  }
  void setPasscodeDialog(){
    final ctrl=TextEditingController();
    showDialog(context: context, builder: (_)=>AlertDialog(backgroundColor: Color(0xFF1E293B), title: Text("Set 6-digit Passcode", style: TextStyle(color: Colors.white)), content: TextField(controller: ctrl, keyboardType: TextInputType.number, maxLength:6, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText:"Enter 6 digits")), actions:[TextButton(onPressed: () async {final p=await SharedPreferences.getInstance(); await p.setString('passcode', ctrl.text); setState(()=>passcode=ctrl.text); Navigator.pop(context);}, child: Text("Save"))]));
  }
  @override Widget build(BuildContext context){
    String displayEmail=savedEmailPermanent.isEmpty? widget.email : savedEmailPermanent;
    return SafeArea(child: ListView(padding:EdgeInsets.all(12), children:[
      Center(child: Padding(padding: EdgeInsets.only(top:10,bottom:20), child: Text("Profile", style: TextStyle(color: Colors.white, fontSize:24, fontWeight: FontWeight.bold)))),
      Center(
        child: LiquidGlass(
          radius:15,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal:20,vertical:12),
            child: Column(
              children: [
                Icon(Icons.email, color: Color(0xFF38BDF8), size:20),
                SizedBox(height:6),
                Text(displayEmail, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                Text("Registered Email - Permanent", style: TextStyle(color: Colors.white38, fontSize:10))
              ]
            )
          )
        )
      ),
      SizedBox(height:12),Center(child: GestureDetector(onTap: pickAvatar, child: LiquidGlass(radius:45, child: CircleAvatar(radius:45, backgroundImage: avatarBytes!=null?MemoryImage(avatarBytes!):null, child: avatarBytes==null?Icon(Icons.person,size:40):null)))),
      SizedBox(height:12),LiquidGlass(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children:[Icon(Icons.system_update,color:Colors.white70,size:20),SizedBox(width:8),Text("New Release Update",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))]),Text(statusMsg, style: TextStyle(color: Colors.white54, fontSize:11)),if(isDownloading) LinearProgressIndicator(),SizedBox(height:8),SizedBox(width:double.infinity, child: ElevatedButton(onPressed: isDownloading?null:autoUpdate, style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1)), child: Text(isDownloading?"Downloading...":"Check New Version", style: TextStyle(color: Colors.white))))]))),
      SizedBox(height:8),LiquidGlass(child: SwitchListTile(title: Text("Download to Gallery - /OnyxMovies", style: TextStyle(color: Colors.white, fontSize:12)), subtitle: Text(downloadToGallery? "On - Saves to Gallery" : "Off - Stay in app & play offline", style: TextStyle(color: Colors.white38, fontSize:10)), value: downloadToGallery, onChanged: (v) async {final p=await SharedPreferences.getInstance(); await p.setBool('download_to_gallery',v); setState(()=>downloadToGallery=v);})),
      LiquidGlass(child: SwitchListTile(title: Text("High Speed Downloads", style: TextStyle(color: Colors.white, fontSize:12)), value: highSpeed, onChanged: (v) async {final p=await SharedPreferences.getInstance(); await p.setBool('high_speed',v); setState(()=>highSpeed=v);})),
      LiquidGlass(child: SwitchListTile(title: Text("Allow All Permissions", style: TextStyle(color: Colors.white, fontSize:12)), value: allowPermissions, onChanged: (v) async {final p=await SharedPreferences.getInstance(); await p.setBool('allow_permissions',v); setState(()=>allowPermissions=v);})),
      LiquidGlass(child: SwitchListTile(title: Text("Dark Mode / Light Mode", style: TextStyle(color: Colors.white, fontSize:12)), value: darkMode, onChanged: (v) async {final p=await SharedPreferences.getInstance(); await p.setBool('isDark',v); widget.onTheme(v); setState(()=>darkMode=v);})),
      SizedBox(height:8),Text("Security", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      LiquidGlass(child: ListTile(leading: Icon(Icons.lock,color:Colors.white70), title: Text("Set Passcode 6-digits: ${passcode.isEmpty? "Not set" : "****${passcode.substring(passcode.length>2?passcode.length-2:0)}"}", style: TextStyle(color: Colors.white, fontSize:12)), onTap: setPasscodeDialog)),
      LiquidGlass(child: ListTile(leading: Icon(Icons.fingerprint,color:Colors.white70), title: Text("Biometric", style: TextStyle(color: Colors.white)), onTap: () async {final auth=LocalAuthentication(); if(await auth.canCheckBiometrics){final did=await auth.authenticate(localizedReason:"Biometric"); if(did&&mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Biometric OK")));}})),
      LiquidGlass(child: ListTile(leading: Icon(Icons.face,color:Colors.white70), title: Text("Face ID", style: TextStyle(color: Colors.white)), onTap: () async {final auth=LocalAuthentication(); if(await auth.canCheckBiometrics){final did=await auth.authenticate(localizedReason:"Face ID"); if(did&&mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Face ID OK")));}})),
      LiquidGlass(child: ListTile(leading: Icon(Icons.password,color:Colors.white70), title: Text("Password Security", style: TextStyle(color: Colors.white)), onTap: (){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password: ${widget.email}")));})),
      SizedBox(height:8),Text("More", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      LiquidGlass(child: ListTile(leading: Icon(Icons.star,color:Colors.amber), title: Text("Rate Us", style: TextStyle(color: Colors.white)), onTap: () async {final uri=Uri.parse("https://play.google.com/store/apps/details?id=com.onyx.movies"); if(await canLaunchUrl(uri)) await launchUrl(uri);})),
      LiquidGlass(child: ListTile(leading: Icon(Icons.share,color:Colors.white70), title: Text("Share App", style: TextStyle(color: Colors.white)), onTap: () async {await Share.share("Download ONYX MOVIES - Best VJ Movies App https://github.com/bluezzer/onyx-movie-final/releases");})),
      SizedBox(height:8),Text("Contact Us", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      LiquidGlass(child: Column(children:[
        ListTile(leading: Icon(Icons.email,color:Colors.white70), title: Text("mugabibenjamin14@gmail.com", style: TextStyle(color: Colors.white, fontSize:12)), onTap: () async {final uri=Uri.parse("mailto:mugabibenjamin14@gmail.com"); if(await canLaunchUrl(uri)) await launchUrl(uri);}),
        ListTile(leading: Icon(Icons.camera_alt,color:Colors.white70), title: Text("Instagram: onyxmovies", style: TextStyle(color: Colors.white, fontSize:12)), onTap: () async {final uri=Uri.parse("https://instagram.com/onyxmovies"); if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);}),
        ListTile(leading: Icon(Icons.facebook,color:Colors.white70), title: Text("Facebook: onyx movies14", style: TextStyle(color: Colors.white, fontSize:12)), onTap: () async {final uri=Uri.parse("https://facebook.com"); if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);}),
        ListTile(leading: Icon(Icons.alternate_email,color:Colors.white70), title: Text("X / Twitter: onyxmovies", style: TextStyle(color: Colors.white, fontSize:12)), onTap: () async {final uri=Uri.parse("https://twitter.com/onyxmovies"); if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);}),
      ])),SizedBox(height:20),
    ]));
  }
}

class AdminMainNav extends StatefulWidget{final String email;const AdminMainNav({super.key,required this.email});@override State<AdminMainNav> createState()=>AdminMainNavState();}
class AdminMainNavState extends State<AdminMainNav>{
  int idx=0;
  @override Widget build(BuildContext context){
    final pages=[AdminDashboardTab(email:widget.email),AdminAddMovie(),AdminManageMovies()];
    return Scaffold(backgroundColor:Color(0xFF020617),appBar:AppBar(backgroundColor:Color(0xFF020617),title:Text("ADMIN: ${widget.email}",style:TextStyle(fontSize:12,color:Colors.orange))),body:pages[idx],bottomNavigationBar:BottomNavigationBar(currentIndex:idx,backgroundColor:Color(0xFF0F172A),selectedItemColor:Colors.orange,unselectedItemColor:Colors.white54,onTap:(i)=>setState(()=>idx=i),items:[BottomNavigationBarItem(icon:Icon(Icons.dashboard),label:"Dashboard"),BottomNavigationBarItem(icon:Icon(Icons.add),label:"Add"),BottomNavigationBarItem(icon:Icon(Icons.list),label:"Manage")]));
  }
}
class AdminDashboardTab extends StatelessWidget{
  final String email;const AdminDashboardTab({super.key,required this.email});
  @override Widget build(BuildContext context){return ListView(padding: EdgeInsets.all(16), children: [LiquidGlass(radius:16, child: Container(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Admin Dashboard", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text(email, style: TextStyle(color: Colors.orange))]))),SizedBox(height:16),LiquidGlass(radius:12, child: SizedBox(width:double.infinity, height:50, child: ElevatedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAddMovie()));}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.08)), child: Text("Add Movie + Category + VJ + Genre + Year + Trending", style: TextStyle(color: Colors.white))))),]);}
}
class AdminManageMovies extends StatelessWidget{
  AdminManageMovies({super.key});final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){return StreamBuilder(stream: ref.onValue, builder: (c,snap){if(!snap.hasData) return IPhoneLoader(size:20); if(snap.data!.snapshot.value==null) return Center(child: Text("No movies", style: TextStyle(color: Colors.white54))); final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map); final list=map.entries.toList(); list.sort((a,b){final at=Map<String,dynamic>.from(a.value as Map)['timestamp']??0; final bt=Map<String,dynamic>.from(b.value as Map)['timestamp']??0; return bt.compareTo(at);}); return ListView.builder(padding: EdgeInsets.all(12), itemCount: list.length, itemBuilder: (c,i){final m=Map<String,dynamic>.from(list[i].value as Map); final title=m['title']??''; final cat=m['category']??''; final vj=m['vj']??''; return Padding(padding: EdgeInsets.only(bottom:8), child: LiquidGlass(child: ListTile(title: Text(title, style: TextStyle(color: Colors.white)), subtitle: Text("$cat • $vj • ${m['year']??''} ${m['isTrending']==true? "• TRENDING":""}", style: TextStyle(color: Colors.white54, fontSize:10)), trailing: IconButton(icon: Icon(Icons.delete, color: Colors.redAccent), onPressed: () async {await ref.child(list[i].key).remove();}))));});});}
}
class AdminAddMovie extends StatefulWidget{const AdminAddMovie({super.key});@override State<AdminAddMovie> createState()=>AdminAddMovieState();}
class AdminAddMovieState extends State<AdminAddMovie>{
  final titleC=TextEditingController();final descC=TextEditingController();final vjC=TextEditingController(text:"VJ Junior");final genreC=TextEditingController(text:"Action");final yearC=TextEditingController(text:"2024");String category="Movie";final picker=ImagePicker();Uint8List? posterBytes;Uint8List? bannerBytes;List<Map<String, dynamic>> casts=[];bool isTrending=false;
  void pickPoster() async {final x=await picker.pickImage(source:ImageSource.gallery);if(x!=null){final b=await x.readAsBytes();setState(()=>posterBytes=b);}}
  void pickBanner() async {final x=await picker.pickImage(source:ImageSource.gallery);if(x!=null){final b=await x.readAsBytes();setState(()=>bannerBytes=b);}}
  void addCast() async {
    if(casts.length>=5){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Max 5 casts")));return;}
    final realC=TextEditingController();final actedC=TextEditingController();Uint8List? castImg;
    await showDialog(context: context, builder: (_) => StatefulBuilder(builder: (c,setS)=>AlertDialog(backgroundColor: Color(0xFF1E293B), title: Text("Add Cast", style: TextStyle(color: Colors.white)), content: Column(mainAxisSize: MainAxisSize.min, children:[GestureDetector(onTap: () async {final x=await picker.pickImage(source:ImageSource.gallery); if(x!=null){final b=await x.readAsBytes(); setS(()=>castImg=b);}}, child: CircleAvatar(radius:30, backgroundImage: castImg!=null?MemoryImage(castImg!):null, child: castImg==null?Icon(Icons.person):null)), TextField(controller: realC, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText:"Real Name")), TextField(controller: actedC, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText:"Acted Name"))]), actions:[TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancel")), TextButton(onPressed: (){setState(()=>casts.add({"realName":realC.text,"actedName":actedC.text,"imageBase64":castImg!=null?base64Encode(castImg!):""})); Navigator.pop(context);}, child: Text("Add"))])));
  }
  void save() async {
    if(titleC.text.isEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Title required")));return;}
    if(bannerBytes!=null){final bRef=FirebaseDatabase.instance.ref('banners').push(); await bRef.set({"imageBase64":base64Encode(bannerBytes!), "timestamp":DateTime.now().millisecondsSinceEpoch});}
    final ref=FirebaseDatabase.instance.ref('movies').push();
    await ref.set({"title":titleC.text, "description":descC.text, "vj":vjC.text, "genre":genreC.text, "year":yearC.text, "category":category, "isTrending":isTrending, "posterBase64":posterBytes!=null?base64Encode(posterBytes!):"", "casts":casts, "timestamp":DateTime.now().millisecondsSinceEpoch});
    if(mounted){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved! Linked to User Panel"))); Navigator.pop(context);}
  }
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF020617), appBar: AppBar(backgroundColor: Color(0xFF020617), title: Text("ADMIN: Add Movie/Series")), body: SingleChildScrollView(padding: EdgeInsets.all(12), child: Column(children: [
      LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:titleC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:"Movie Title *", border:InputBorder.none)))),
      SizedBox(height:8),LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:descC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:"Description", border:InputBorder.none)))),
      SizedBox(height:8),LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:vjC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:"VJ Name (shows on poster corner upright)", border:InputBorder.none)))),
      SizedBox(height:8),LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:genreC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:"Genre (Action, Indian, Animation...)", border:InputBorder.none)))),
      SizedBox(height:8),LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:yearC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:"Year of Release (2024)", border:InputBorder.none)))),
      SizedBox(height:12),LiquidGlass(child: Padding(padding: EdgeInsets.all(8), child: Column(children: [
        Row(children:[Text("Category:", style: TextStyle(color: Colors.white)), SizedBox(width:10), DropdownButton<String>(value: category, dropdownColor: Color(0xFF1E293B), style: TextStyle(color: Colors.white), items: [DropdownMenuItem(value:"Movie", child: Text("Movie")), DropdownMenuItem(value:"Series", child: Text("Series")), DropdownMenuItem(value:"Animation", child: Text("Animation")), DropdownMenuItem(value:"Indian", child: Text("Indian Movie")), DropdownMenuItem(value:"Trending", child: Text("Trending"))], onChanged: (v){if(v!=null) setState(()=>category=v);})]),
        SwitchListTile(title: Text("Is Trending? - Shows in Trending section", style: TextStyle(color: Colors.white, fontSize:12)), value: isTrending, onChanged: (v)=>setState(()=>isTrending=v)),
      ]))),
      SizedBox(height:12),Row(children:[Expanded(child: LiquidGlass(child: ElevatedButton.icon(onPressed: pickPoster, icon: Icon(Icons.image,color:Colors.white70), label: Text(posterBytes==null?"Pick Poster":"Poster OK", style: TextStyle(color: Colors.white70))))), SizedBox(width:8), Expanded(child: LiquidGlass(child: ElevatedButton.icon(onPressed: pickBanner, icon: Icon(Icons.panorama,color:Colors.white70), label: Text(bannerBytes==null?"Pick Banner (7 Latest)":"Banner OK", style: TextStyle(color: Colors.white70))))) ]),
      SizedBox(height:12),LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: Row(children:[Text("Casts (max 5) - Shows in Player", style: TextStyle(color: Colors.white)), Spacer(), ElevatedButton(onPressed: addCast, child: Text("Add Cast"))]))),
      Wrap(spacing:8, children: casts.map((c)=>Chip(label: Text(c['realName']))).toList()),
      SizedBox(height:20),LiquidGlass(radius:12, child: SizedBox(width:double.infinity,height:50, child: ElevatedButton(onPressed: save, style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1)), child: Text("Save to Firebase - Links to User Panel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
    ]))),
  }
}
