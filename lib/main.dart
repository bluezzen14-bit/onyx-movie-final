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
      Expanded(child:ClipRRect(borderRadius:const BorderRadius.vertical(top:Radius.circular(12)), child:poster.toString().length>100?Image.memory(base64Decode(poster.toString().split(',').last), fit:BoxFit.cover, width:double.infinity, errorBuilder:(a,b,c)=>const Icon(Icons.movie)):const Center(child:Icon(Icons.movie, size:40)))),
      Padding(padding:const EdgeInsets.all(6), child:Text(data['title']??'No Title', maxLines:1, overflow:TextOverflow.ellipsis, style:const TextStyle(color:Colors.white, fontWeight:FontWeight.bold, fontSize:12))),
      Padding(padding:const EdgeInsets.only(left:6, bottom:6), child:Text("${data['vj']??'VJ Junior'} • ${data['genre']??'Action'}", style:const TextStyle(color:Colors.white54, fontSize:10))),
    ])));
  }
}

class DetailPage extends StatelessWidget {
  final Map<String,dynamic> data; final String id;
  const DetailPage({super.key, required this.data, required this.id});
  @override
  Widget build(BuildContext context){
    final casts=data['casts'] is List? data['casts'] as List : [];
    return Scaffold(appBar:AppBar(backgroundColor:const Color(0xFF020617), title:Text(data['title']??'')), body:SingleChildScrollView(padding:const EdgeInsets.all(12), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
      ClipRRect(borderRadius:BorderRadius.circular(12), child:AspectRatio(aspectRatio:16/9, child:Container(color:const Color(0xFF1E293B), child:const Icon(Icons.play_circle, size:60)))),
      const SizedBox(height:12), Text(data['title']??'', style:const TextStyle(fontSize:20, fontWeight:FontWeight.bold)), const SizedBox(height:6),
      Text("${data['vj']??''} | ${data['genre']??''}", style:const TextStyle(color:Colors.white54)), const SizedBox(height:12),
      const Text("Casts - 5 circle + Real + Acted", style:TextStyle(fontSize:16, fontWeight:FontWeight.bold)), const SizedBox(height:8),
      casts.isEmpty?const Text("No casts", style:TextStyle(color:Colors.white54)):SizedBox(height:120, child:ListView.builder(scrollDirection:Axis.horizontal, itemCount:casts.length>5?5:casts.length, itemBuilder:(c,i){final cast=Map<String,dynamic>.from(casts[i] as Map); final img=cast['imageBase64']??''; return Container(width:80, margin:const EdgeInsets.only(right:10), child:Column(children:[CircleAvatar(radius:30, backgroundColor:const Color(0xFF1E293B), backgroundImage:img.toString().length>100?MemoryImage(base64Decode(img.toString().split(',').last)):null, child:img.toString().length<100?const Icon(Icons.person):null), const SizedBox(height:4), Text(cast['realName']??'', maxLines:1, style:const TextStyle(fontSize:10, fontWeight:FontWeight.bold)), Text("as ${cast['actedName']??''}", maxLines:1, style:const TextStyle(fontSize:9, color:Colors.white54))])) ;})),
      const SizedBox(height:12), Text(data['description']??'No description', style:const TextStyle(color:Colors.white70)),
    ])));
  }
}

class SearchTab extends StatefulWidget {const SearchTab({super.key}); @override State<SearchTab> createState()=>_SearchTabState();}
class _SearchTabState extends State<SearchTab>{
  String q=""; final ref=FirebaseDatabase.instance.ref('movies');
  @override
  Widget build(BuildContext context){
    return SafeArea(child:Column(children:[
      Padding(padding:const EdgeInsets.all(12), child:TextField(onChanged:(v)=>setState(()=>q=v.toLowerCase()), decoration:InputDecoration(hintText:"Search Movies, VJ, Genre...", prefixIcon:const Icon(Icons.search), filled:true, fillColor:const Color(0xFF1E293B), border:OutlineInputBorder(borderRadius:BorderRadius.circular(12), borderSide:BorderSide.none)))),
      Expanded(child:StreamBuilder(stream:ref.onValue, builder:(c,snap){ if(!snap.hasData||snap.data!.snapshot.value==null) return const Center(child:Text("No data", style:TextStyle(color:Colors.white54))); final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map); final filtered=map.entries.where((e){final m=Map<String,dynamic>.from(e.value as Map); final t="${m['title']}${m['vj']}${m['genre']}".toLowerCase(); return t.contains(q);}).toList(); return ListView.builder(itemCount:filtered.length, itemBuilder:(c,i){final m=Map<String,dynamic>.from(filtered[i].value as Map); return ListTile(leading:const Icon(Icons.movie, color:Color(0xFF38BDF8)), title:Text(m['title']??''), subtitle:Text("${m['vj']??''} • ${m['genre']??''}"), onTap:()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>DetailPage(data:m, id:filtered[i].key))));});})),
    ]));
  }
}

class DownloadsTab extends StatefulWidget {const DownloadsTab({super.key}); @override State<DownloadsTab> createState()=>_DownloadsTabState();}
class _DownloadsTabState extends State<DownloadsTab> with SingleTickerProviderStateMixin{
  late TabController tab; @override void initState(){super.initState(); tab=TabController(length:2, vsync:this);}
  @override
  Widget build(BuildContext context){
    return SafeArea(child:Column(children:[
      Container(margin:const EdgeInsets.all(12), padding:const EdgeInsets.all(12), decoration:BoxDecoration(color:const Color(0xFF1E293B), borderRadius:BorderRadius.circular(12)), child:Row(children:[const Icon(Icons.storage_rounded, color:Color(0xFF38BDF8)), const SizedBox(width:10), const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text("Used: 3.2GB / 15.7GB", style:TextStyle(color:Colors.white, fontSize:12)), SizedBox(height:4), LinearProgressIndicator(value:0.2, backgroundColor:Colors.white12, color:Color(0xFF38BDF8)), SizedBox(height:4), Text("Free: 12.5GB available", style:TextStyle(color:Colors.white54, fontSize:10))]))])),
      TabBar(controller:tab, labelColor:const Color(0xFF38BDF8), tabs:const [Tab(text:"Downloading"), Tab(text:"Completed")]),
      Expanded(child:TabBarView(controller:tab, children:const [
        Center(child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[Icon(Icons.downloading_rounded, size:80, color:Colors.white24), SizedBox(height:10), Text("No active downloads", style:TextStyle(color:Colors.white54))])),
        Center(child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[Icon(Icons.download_done_rounded, size:80, color:Colors.white24), SizedBox(height:10), Text("No available download", style:TextStyle(color:Colors.white54)), SizedBox(height:4), Text("Your downloaded movies will appear here", style:TextStyle(color:Colors.white30, fontSize:12))])),
      ])),
    ]));
  }
}

class DashboardTab extends StatefulWidget {const DashboardTab({super.key}); @override State<DashboardTab> createState()=>_DashboardTabState();}
class _DashboardTabState extends State<DashboardTab>{
  String period="Week"; final periods=["Day","Week","Month","Year"];
  @override
  Widget build(BuildContext context){
    final data=period=="Day"?[3,5,2,8,4]:period=="Week"?[12,19,8,15,22,18,25]:period=="Month"?[45,60,35,80]:[200,350,280,420];
    return SafeArea(child:Padding(padding:const EdgeInsets.all(12), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
      const Text("Analytics Dashboard", style:TextStyle(fontSize:20, fontWeight:FontWeight.bold)), const SizedBox(height:12),
      Row(children:periods.map((p){final sel=p==period; return Expanded(child:GestureDetector(onTap:()=>setState(()=>period=p), child:Container(margin:const EdgeInsets.only(right:6), padding:const EdgeInsets.symmetric(vertical:8), decoration:BoxDecoration(color:sel?const Color(0xFF38BDF8):const Color(0xFF1E293B), borderRadius:BorderRadius.circular(8)), child:Center(child:Text(p, style:TextStyle(color:sel?Colors.black:Colors.white, fontWeight:FontWeight.bold, fontSize:12))))));}).toList()),
      const SizedBox(height:20),
      Row(children:[_statCard(Icons.visibility_rounded,"Views","12.5K"), const SizedBox(width:8), _statCard(Icons.download_rounded,"Downloads","3.2K"), const SizedBox(width:8), _statCard(Icons.people_rounded,"Users","1.1K")]),
      const SizedBox(height:20),
      Expanded(child:Container(padding:const EdgeInsets.all(12), decoration:BoxDecoration(color:const Color(0xFF1E293B), borderRadius:BorderRadius.circular(12)), child:Row(crossAxisAlignment:CrossAxisAlignment.end, children:List.generate(data.length,(i){final maxV=data.reduce((a,b)=>a>b?a:b).toDouble(); return Expanded(child:Container(margin:const EdgeInsets.symmetric(horizontal:4), child:Column(mainAxisAlignment:MainAxisAlignment.end, children:[Container(height:(data[i]/maxV)*150, decoration:BoxDecoration(color:const Color(0xFF38BDF8), borderRadius:BorderRadius.circular(6))), const SizedBox(height:6), Text("${data[i]}", style:const TextStyle(fontSize:10, color:Colors.white54))])));}))),
    ])));
  }
  Widget _statCard(IconData icon, String label, String value){return Expanded(child:Container(padding:const EdgeInsets.all(10), decoration:BoxDecoration(color:const Color(0xFF1E293B), borderRadius:BorderRadius.circular(10)), child:Column(children:[Icon(icon, color:const Color(0xFF38BDF8), size:20), const SizedBox(height:4), Text(value, style:const TextStyle(fontWeight:FontWeight.bold)), Text(label, style:const TextStyle(fontSize:10, color:Colors.white54))])));}
}

class ProfileTab extends StatefulWidget {
  final Function(bool) onTheme; const ProfileTab({super.key, required this.onTheme});
  @override State<ProfileTab> createState()=>_ProfileTabState();
}
class _ProfileTabState extends State<ProfileTab>{
  bool isDark=true; bool galleryMode=true; final picker=ImagePicker(); Uint8List? avatarBytes;
  Future<void> pickAvatar() async {final x=await picker.pickImage(source:ImageSource.gallery); if(x!=null){final b=await x.readAsBytes(); setState(()=>avatarBytes=b); final p=await SharedPreferences.getInstance(); await p.setString('avatar', base64Encode(b));}}
  @override void initState(){super.initState(); _load();}
  Future<void> _load() async {final p=await SharedPreferences.getInstance(); isDark=p.getBool('isDark')??true; galleryMode=p.getBool('galleryMode')??true; final av=p.getString('avatar'); if(av!=null) setState(()=>avatarBytes=base64Decode(av));}
  @override Widget build(BuildContext context){
    return SafeArea(child:ListView(padding:const EdgeInsets.all(12), children:[
      Center(child:GestureDetector(onTap:pickAvatar, child:CircleAvatar(radius:45, backgroundColor:const Color(0xFF1E293B), backgroundImage:avatarBytes!=null?MemoryImage(avatarBytes!):null, child:avatarBytes==null?const Icon(Icons.person, size:40):null))),
      const SizedBox(height:10), const Center(child:Text("Tap to change avatar from Gallery", style:TextStyle(color:Colors.white54, fontSize:12))), const SizedBox(height:20),
      Container(decoration:BoxDecoration(color:const Color(0xFF38BDF8), borderRadius:BorderRadius.circular(12)), child:ListTile(leading:const Icon(Icons.add_box_rounded, color:Colors.black), title:const Text("ADMIN: Add New Movie", style:TextStyle(color:Colors.black, fontWeight:FontWeight.bold)), subtitle:const Text("Gallery poster/banner + 5 casts", style:TextStyle(color:Colors.black54, fontSize:11)), onTap:()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>const AdminAddMovie())))),
      const SizedBox(height:12),
      ListTile(title:const Text("Theme Dark"), trailing:Switch(value:isDark, onChanged:(v) async {setState(()=>isDark=v); widget.onTheme(v); final p=await SharedPreferences.getInstance(); await p.setBool('isDark', v);})),
      ListTile(title:const Text("Gallery Mode Switch"), trailing:Switch(value:galleryMode, onChanged:(v) async {setState(()=>galleryMode=v); final p=await SharedPreferences.getInstance(); await p.setBool('galleryMode', v);})),
      const Divider(color:Colors.white12),
      ListTile(leading:const Icon(Icons.download_rounded, color:Color(0xFF38BDF8)), title:const Text("Download Latest & Install"), subtitle:const Text("Get V1.1.0 APK", style:TextStyle(fontSize:12, color:Colors.white54)), onTap:() async {final uri=Uri.parse("https://github.com/bluezzer/onyx-movie-final/releases"); if(await canLaunchUrl(uri)) await launchUrl(uri, mode:LaunchMode.externalApplication);}),
      ListTile(leading:const Icon(Icons.security_rounded, color:Color(0xFF38BDF8)), title:const Text("Security - Biometric / Passcode"), onTap:() async {final auth=LocalAuthentication(); final can=await auth.canCheckBiometrics; if(can){final did=await auth.authenticate(localizedReason:"Authenticate to open ONYX"); if(did&&mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Authenticated ✅")));}}),
      ListTile(leading:const Icon(Icons.contact_mail_rounded, color:Color(0xFF38BDF8)), title:const Text("Contact Us"), onTap:() async {final uri=Uri.parse("mailto:support@onyxmovies.com"); if(await canLaunchUrl(uri)) await launchUrl(uri);}),
      ListTile(leading:const Icon(Icons.app_registration_rounded, color:Color(0xFF38BDF8)), title:const Text("Register / Sign Up"), onTap:(){showDialog(context:context, builder:(_)=>AlertDialog(title:const Text("Register"), content:const Column(mainAxisSize:MainAxisSize.min, children:[TextField(decoration:InputDecoration(labelText:"Email")), TextField(decoration:InputDecoration(labelText:"Password"), obscureText:true)]), actions:[TextButton(onPressed:()=>Navigator.pop(context), child:const Text("Sign Up"))]));}),
    ]));
  }
}

class AdminAddMovie extends StatefulWidget {const AdminAddMovie({super.key}); @override State<AdminAddMovie> createState()=>_AdminAddMovieState();}
class _AdminAddMovieState extends State<AdminAddMovie>{
  final titleC=TextEditingController(); final descC=TextEditingController(); final vjC=TextEditingController(text:"VJ Junior"); final genreC=TextEditingController(text:"Action"); final picker=ImagePicker();
  Uint8List? posterBytes; Uint8List? bannerBytes; List<Map<String,dynamic>> casts=[];
  Future<void> pickPoster() async {final x=await picker.pickImage(source:ImageSource.gallery); if(x!=null){final b=await x.readAsBytes(); setState(()=>posterBytes=b);}}
  Future<void> pickBanner() async {final x=await picker.pickImage(source:ImageSource.gallery); if(x!=null){final b=await x.readAsBytes(); setState(()=>bannerBytes=b);}}
  Future<void> addCast() async {
    if(casts.length>=5){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Max 5 casts"))); return;}
    final realC=TextEditingController(); final actedC=TextEditingController(); Uint8List? castImg;
    await showDialog(context:context, builder:(_)=>StatefulBuilder(builder:(c,setS)=>AlertDialog(
      title:const Text("Add Cast"),
      content:Column(mainAxisSize:MainAxisSize.min, children:[
        GestureDetector(onTap:() async {final x=await picker.pickImage(source:ImageSource.gallery); if(x!=null){final b=await x.readAsBytes(); setS(()=>castImg=b);}}, child:CircleAvatar(radius:30, backgroundImage:castImg!=null?MemoryImage(castImg!):null, child:castImg==null?const Icon(Icons.person):null)),
        TextField(controller:realC, decoration:const InputDecoration(labelText:"Real Name")),
        TextField(controller:actedC, decoration:const InputDecoration(labelText:"Acted Name")),
      ]),
      actions:[TextButton(onPressed:()=>Navigator.pop(context), child:const Text("Cancel")), TextButton(onPressed:(){setState(()=>casts.add({"realName":realC.text, "actedName":actedC.text, "imageBase64":castImg!=null?base64Encode(castImg!):""})); Navigator.pop(context);}, child:const Text("Add"))],
    )));
  }
  Future<void> save() async {
    if(titleC.text.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Title required"))); return;}
    final ref=FirebaseDatabase.instance.ref('movies').push();
    await ref.set({"title":titleC.text, "description":descC.text, "vj":vjC.text, "genre":genreC.text, "category":genreC.text, "posterBase64":posterBytes!=null?base64Encode(posterBytes!):"", "bannerBase64":bannerBytes!=null?base64Encode(bannerBytes!):"", "casts":casts, "timestamp":DateTime.now().millisecondsSinceEpoch});
    if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Movie Added ✅ - Check Home"))); Navigator.pop(context);}
  }
  @override Widget build(BuildContext context){
    return Scaffold(appBar:AppBar(title:const Text("ADMIN: Add Movie - Gallery")), body:SingleChildScrollView(padding:const EdgeInsets.all(12), child:Column(children:[
      TextField(controller:titleC, decoration:const InputDecoration(labelText:"Movie Title *")),
      TextField(controller:descC, decoration:const InputDecoration(labelText:"Description")),
      TextField(controller:vjC, decoration:const InputDecoration(labelText:"VJ Name - will appear in search")),
      TextField(controller:genreC, decoration:const InputDecoration(labelText:"Genre - will appear in search")),
      const SizedBox(height:12),
      Row(children:[Expanded(child:ElevatedButton.icon(onPressed:pickPoster, icon:const Icon(Icons.image), label:Text(posterBytes==null?"Pick Poster (Gallery)":"Poster ✅"))), const SizedBox(width:8), Expanded(child:ElevatedButton.icon(onPressed:pickBanner, icon:const Icon(Icons.panorama), label:Text(bannerBytes==null?"Pick Banner (Gallery)":"Banner ✅")))]),
      const SizedBox(height:12),
      Row(children:[const Text("Casts (max 5)"), const Spacer(), ElevatedButton(onPressed:addCast, child:const Text("Add Cast"))]),
      const SizedBox(height:8),
      Wrap(spacing:8, children:casts.map((c)=>Chip(label:Text(c['realName']), avatar:CircleAvatar(backgroundImage:c['imageBase64'].toString().isNotEmpty?MemoryImage(base64Decode(c['imageBase64'])):null))).toList()),
      const SizedBox(height:20),
      SizedBox(width:double.infinity, child:ElevatedButton(onPressed:save, style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF38BDF8), padding:const EdgeInsets.symmetric(vertical:14)), child:const Text("Save Movie to Firebase", style:TextStyle(color:Colors.black, fontWeight:FontWeight.bold)))),
    ])));
  }
}
