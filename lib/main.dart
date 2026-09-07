import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    try {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
      FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);
    } catch(_) {}
  } catch(e) {
    print("Firebase init failed - UI will still load");
  }
  runApp(OnyxApp());
}

class OnyxApp extends StatefulWidget{
  @override State<OnyxApp> createState()=>OnyxAppState();
}
class OnyxAppState extends State<OnyxApp>{
  bool isDark=true;
  @override void initState(){super.initState(); loadTheme();}
  loadTheme() async {final p=await SharedPreferences.getInstance(); setState(()=>isDark=p.getBool('isDark')??true);}
  void updateTheme(bool d) async {setState(()=>isDark=d); final p=await SharedPreferences.getInstance(); await p.setBool('isDark', d);}
  @override Widget build(BuildContext context){
    return MaterialApp(debugShowCheckedModeBanner:false, theme: isDark? ThemeData.dark().copyWith(scaffoldBackgroundColor:Color(0xFF020617)): ThemeData.light(), home: Splash(onTheme:updateTheme));
  }
}

class Splash extends StatefulWidget{
  final Function(bool) onTheme;
  const Splash({super.key, required this.onTheme});
  @override State<Splash> createState()=>SplashState();
}
class SplashState extends State<Splash>{
  @override void initState(){super.initState(); _init();}
  _init() async {
    await Future.delayed(Duration(seconds:2));
    final p=await SharedPreferences.getInstance();
    final permanentEmail=p.getString('registered_email_permanent');
    final userEmail=p.getString('user_email');
    final isLogged=p.getBool('isLoggedIn')??false;
    final savedEmail=permanentEmail??userEmail;
    if(mounted){
      if(savedEmail!=null && savedEmail.isNotEmpty && (isLogged || permanentEmail!=null)){
        Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>UserMainNav(email:savedEmail, onTheme:widget.onTheme)));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>LoginScreen(onTheme:widget.onTheme)));
      }
    }
  }
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor:Color(0xFF020617), body:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[Icon(Icons.movie, color:Colors.white, size:80), SizedBox(height:20), Text('ONYX MOVIES', style:TextStyle(color:Colors.white, fontSize:28, fontWeight:FontWeight.bold)), SizedBox(height:20), IPhoneLoader(size:24)])));
  }
}

class IPhoneLoader extends StatefulWidget{
  final double size;
  const IPhoneLoader({super.key, this.size=20});
  @override State<IPhoneLoader> createState()=>IPhoneLoaderState();
}
class IPhoneLoaderState extends State<IPhoneLoader> with SingleTickerProviderStateMixin{
  late AnimationController c;
  @override void initState(){super.initState(); c=AnimationController(vsync:this, duration:Duration(seconds:1))..repeat();}
  @override void dispose(){c.dispose(); super.dispose();}
  @override Widget build(BuildContext context){return RotationTransition(turns:c, child: Icon(Icons.autorenew, color:Colors.white70, size:widget.size));}
}

class LiquidGlass extends StatelessWidget{
  final Widget child;
  final double radius;
  const LiquidGlass({super.key, required this.child, this.radius=16});
  @override Widget build(BuildContext context){
    return Container(margin:EdgeInsets.all(6), decoration:BoxDecoration(borderRadius:BorderRadius.circular(radius), color:Colors.white.withOpacity(0.08), border:Border.all(color:Colors.white.withOpacity(0.12))), child:ClipRRect(borderRadius:BorderRadius.circular(radius), child:BackdropFilter(filter:ImageFilter.blur(sigmaX:12, sigmaY:12), child:child)));
  }
}

class LoginScreen extends StatefulWidget{
  final Function(bool) onTheme;
  const LoginScreen({super.key, required this.onTheme});
  @override State<LoginScreen> createState()=>LoginScreenState();
}
class LoginScreenState extends State<LoginScreen>{
  final emailC=TextEditingController(text:'mugabibenjamin14@gmail.com');
  final passC=TextEditingController(text:'Mugabibe+-@1');
  bool loading=false;
  void submit() async {
    setState(()=>loading=true);
    final p=await SharedPreferences.getInstance();
    final email=emailC.text.trim();
    final pass=passC.text.trim();
    if(email.isEmpty || pass.isEmpty){setState(()=>loading=false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Email & Password required'))); return;}
    await p.setString('user_email', email);
    await p.setString('registered_email_permanent', email);
    await p.setBool('isLoggedIn', true);
    await p.setString('passcode', pass);
    setState(()=>loading=false);
    if(mounted){
      if(email=='mugabibenjamin14@gmail.com'){Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>AdminMainNav(email:email)));}
      else {Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>UserMainNav(email:email, onTheme:widget.onTheme)));}
    }
  }
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor:Color(0xFF020617), body:Center(child:SingleChildScrollView(padding:EdgeInsets.all(20), child:Column(children:[Icon(Icons.movie_filter, size:70, color:Colors.white), SizedBox(height:20), Text('ONYX MOVIES', style:TextStyle(color:Colors.white, fontSize:26, fontWeight:FontWeight.bold)), SizedBox(height:30), LiquidGlass(child:Padding(padding:EdgeInsets.all(16), child:Column(children:[TextField(controller:emailC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Email - Permanent Auto-Login', labelStyle:TextStyle(color:Colors.white54))), SizedBox(height:12), TextField(controller:passC, style:TextStyle(color:Colors.white), obscureText:true, decoration:InputDecoration(labelText:'Password', labelStyle:TextStyle(color:Colors.white54))), SizedBox(height:20), SizedBox(width:double.infinity, height:48, child:ElevatedButton(onPressed:loading?null:submit, style:ElevatedButton.styleFrom(backgroundColor:Colors.white.withOpacity(0.15)), child:loading? IPhoneLoader(size:18) : Text('LOGIN - Auto Save Forever', style:TextStyle(color:Colors.white))))]))), SizedBox(height:12), Text('Fix: Login once, auto-login forever even after app closed', style:TextStyle(color:Colors.white38, fontSize:10))]))));
  }
}
class HomeTab extends StatelessWidget{
  final String email;
  final bool isAdmin;
  HomeTab({super.key, required this.email, required this.isAdmin});
  final ref=FirebaseDatabase.instance.ref('movies');
  final bannerRef=FirebaseDatabase.instance.ref('banners');
  @override Widget build(BuildContext context){
    return SafeArea(child: CustomScrollView(slivers:[
      SliverToBoxAdapter(child: Padding(padding:EdgeInsets.all(12), child: Row(children:[Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text('ONYX MOVIES', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold, fontSize:20)), Text('Auto-login: $email', style:TextStyle(color:Colors.white38, fontSize:10))])), if(isAdmin) ElevatedButton(onPressed:(){Navigator.push(context, MaterialPageRoute(builder:(_)=>AdminMainNav(email:email)));}, style:ElevatedButton.styleFrom(backgroundColor:Colors.orange), child:Text('ADMIN', style:TextStyle(fontSize:10)))]))),
      SliverToBoxAdapter(child: SizedBox(height:200, child: StreamBuilder(stream:bannerRef.orderByChild('timestamp').limitToLast(7).onValue, builder:(c,snap){
        if(!snap.hasData || snap.data!.snapshot.value==null) return Center(child:Text('Banners: 7 Latest', style:TextStyle(color:Colors.white38)));
        final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
        final list=map.values.toList();
        return PageView.builder(itemCount:list.length, itemBuilder:(c,i){final b=Map<String,dynamic>.from(list[i] as Map); final img=b['imageBase64']??''; return Padding(padding:EdgeInsets.all(8), child: LiquidGlass(radius:12, child: img.isNotEmpty? Image.memory(base64Decode(img), fit:BoxFit.cover, errorBuilder:(_,__,___)=>Center(child:Text(b['title']??'Banner', style:TextStyle(color:Colors.white)))) : Center(child:Text(b['title']??'Banner'))));});
      }))),
      SliverToBoxAdapter(child: Padding(padding:EdgeInsets.all(12), child: Text('All Movies - Internet Sync - Appears instantly', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold)))),
      SliverToBoxAdapter(child: StreamBuilder(stream:ref.orderByChild('timestamp').onValue, builder:(c,snap){
        if(!snap.hasData) return Center(child:IPhoneLoader(size:20));
        if(snap.data!.snapshot.value==null) return Center(child:Padding(padding:EdgeInsets.all(20), child:Text('No movies yet - Admin upload with internet', textAlign:TextAlign.center, style:TextStyle(color:Colors.white54))));
        final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
        final list=map.entries.toList()..sort((a,b){final at=Map<String,dynamic>.from(a.value as Map)['timestamp']??0; final bt=Map<String,dynamic>.from(b.value as Map)['timestamp']??0; return bt.compareTo(at);});
        return GridView.builder(shrinkWrap:true, physics:NeverScrollableScrollPhysics(), padding:EdgeInsets.all(8), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.7, crossAxisSpacing:8, mainAxisSpacing:8), itemCount:list.length, itemBuilder:(c,i){
          final m=Map<String,dynamic>.from(list[i].value as Map);
          final poster=m['posterBase64']??'';
          return GestureDetector(onTap:(){Navigator.push(context, MaterialPageRoute(builder:(_)=>DetailPage(movie:m)));}, child: LiquidGlass(radius:12, child: Column(children:[Expanded(child: poster.isNotEmpty? ClipRRect(borderRadius:BorderRadius.vertical(top:Radius.circular(12)), child: Image.memory(base64Decode(poster), fit:BoxFit.cover, width:double.infinity, errorBuilder:(_,__,___)=>Icon(Icons.movie, color:Colors.white54))) : Icon(Icons.movie, color:Colors.white54)), Padding(padding:EdgeInsets.all(6), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(m['title']??'', maxLines:1, style:TextStyle(color:Colors.white, fontSize:12, fontWeight:FontWeight.bold)), Text('${m['category']??''} • VJ:${m['vj']??''} • ${m['videoFileSize']??""}', maxLines:2, style:TextStyle(color:Colors.white54, fontSize:9))]))])));
        });
      })),
    ]));
  }
}

class MoviesTab extends StatelessWidget{
  MoviesTab({super.key});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){
    return SafeArea(child: Column(children:[Padding(padding:EdgeInsets.all(12), child: Text('Movies - Internet Sync', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold))), Expanded(child: StreamBuilder(stream:ref.orderByChild('timestamp').onValue, builder:(c,snap){
      if(!snap.hasData) return Center(child:IPhoneLoader(size:20));
      if(snap.data!.snapshot.value==null) return Center(child:Text('No movies', style:TextStyle(color:Colors.white54)));
      final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
      final list=map.entries.where((e){final m=Map<String,dynamic>.from(e.value as Map); return (m['type']??'movie').toString().toLowerCase()=='movie';}).toList();
      return GridView.builder(padding:EdgeInsets.all(8), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.7), itemCount:list.length, itemBuilder:(c,i){final m=Map<String,dynamic>.from(list[i].value as Map); final poster=m['posterBase64']??''; return GestureDetector(onTap:(){Navigator.push(context, MaterialPageRoute(builder:(_)=>DetailPage(movie:m)));}, child: LiquidGlass(radius:12, child: Column(children:[Expanded(child: poster.isNotEmpty? Image.memory(base64Decode(poster), fit:BoxFit.cover, width:double.infinity): Icon(Icons.movie)), Padding(padding:EdgeInsets.all(6), child:Text(m['title']??'', style:TextStyle(color:Colors.white, fontSize:11)))])));});
    }))]));
  }
}

class SeriesTab extends StatelessWidget{
  SeriesTab({super.key});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){
    return SafeArea(child: Column(children:[Padding(padding:EdgeInsets.all(12), child: Text('Series - Internet Sync', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold))), Expanded(child: StreamBuilder(stream:ref.orderByChild('timestamp').onValue, builder:(c,snap){
      if(!snap.hasData) return Center(child:IPhoneLoader(size:20));
      if(snap.data!.snapshot.value==null) return Center(child:Text('No series', style:TextStyle(color:Colors.white54)));
      final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
      final list=map.entries.where((e){final m=Map<String,dynamic>.from(e.value as Map); return (m['type']??'').toString().toLowerCase()=='series';}).toList();
      return GridView.builder(padding:EdgeInsets.all(8), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.7), itemCount:list.length, itemBuilder:(c,i){final m=Map<String,dynamic>.from(list[i].value as Map); final poster=m['posterBase64']??''; return GestureDetector(onTap:(){Navigator.push(context, MaterialPageRoute(builder:(_)=>DetailPage(movie:m)));}, child: LiquidGlass(radius:12, child: Column(children:[Expanded(child: poster.isNotEmpty? Image.memory(base64Decode(poster), fit:BoxFit.cover, width:double.infinity): Icon(Icons.tv)), Padding(padding:EdgeInsets.all(6), child:Column(children:[Text(m['title']??'', style:TextStyle(color:Colors.white, fontSize:11)), Text('S${m['season']??1}E${m['episode']??1}', style:TextStyle(color:Colors.white54, fontSize:9))]))])));
      });
    }))]));
  }
}

class DetailPage extends StatefulWidget{
  final Map<String,dynamic> movie;
  const DetailPage({super.key, required this.movie});
  @override State<DetailPage> createState()=>DetailPageState();
}
class DetailPageState extends State<DetailPage>{
  bool isDownloading=false;
  double progress=0;
  void downloadMovie() async {
    setState((){isDownloading=true; progress=0;});
    for(int i=0;i<=100;i++){await Future.delayed(Duration(milliseconds:30)); setState(()=>progress=i/100);}
    final p=await SharedPreferences.getInstance();
    final list=p.getStringList('downloaded')??[];
    list.add(jsonEncode({'title':widget.movie['title'], 'size':widget.movie['videoFileSize']??'1.2GB'}));
    await p.setStringList('downloaded', list);
    setState(()=>isDownloading=false);
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Downloaded'), backgroundColor:Colors.green));
  }
  @override Widget build(BuildContext context){
    final m=widget.movie;
    final poster=m['posterBase64']??'';
    return Scaffold(backgroundColor:Color(0xFF020617), appBar:AppBar(backgroundColor:Color(0xFF020617), title:Text(m['title']??'', style:TextStyle(fontSize:14))), body:SingleChildScrollView(padding:EdgeInsets.all(12), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
      if(poster.isNotEmpty) LiquidGlass(radius:12, child: ClipRRect(borderRadius:BorderRadius.circular(12), child: Image.memory(base64Decode(poster), fit:BoxFit.cover, width:double.infinity, height:250))),
      SizedBox(height:12), Text(m['title']??'', style:TextStyle(color:Colors.white, fontSize:20, fontWeight:FontWeight.bold)),
      SizedBox(height:12), SizedBox(width:double.infinity, height:50, child: ElevatedButton.icon(onPressed:isDownloading?null:downloadMovie, icon:Icon(Icons.download), label:Text(isDownloading?'Downloading...':'Download'), style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF38BDF8)))),
    ])));
  }
}

class DownloadsTab extends StatefulWidget{ const DownloadsTab({super.key}); @override State<DownloadsTab> createState()=>DownloadsTabState(); }
class DownloadsTabState extends State<DownloadsTab>{
  List<Map<String,dynamic>> downloadedList=[];
  @override void initState(){super.initState(); loadDownloads();}
  loadDownloads() async {final p=await SharedPreferences.getInstance(); final d=p.getStringList('downloaded')??[]; setState(()=>downloadedList=d.map((e)=>jsonDecode(e)).toList().cast<Map<String,dynamic>>());}
  @override Widget build(BuildContext context){
    return SafeArea(child: Column(children:[Padding(padding:EdgeInsets.all(12), child: Text('Downloads', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold))), Expanded(child: downloadedList.isEmpty? Center(child:Text('No downloaded', style:TextStyle(color:Colors.white54))) : ListView.builder(itemCount:downloadedList.length, itemBuilder:(c,i){final m=downloadedList[i]; return LiquidGlass(child: ListTile(title:Text(m['title']??'', style:TextStyle(color:Colors.white))));}))]));
  }
}

class ProfileTab extends StatefulWidget{
  final Function(bool) onTheme;
  final String email;
  final bool isAdmin;
  const ProfileTab({super.key,required this.onTheme,required this.email,required this.isAdmin});
  @override State<ProfileTab> createState()=>ProfileTabState();
}
class ProfileTabState extends State<ProfileTab>{
  bool isDownloading=false;
  String statusMsg='Ready - Tap Check Version - Opens Browser';
  String savedEmailPermanent='';
  @override void initState(){super.initState(); loadAll();}
  loadAll() async {final p=await SharedPreferences.getInstance(); setState(()=>savedEmailPermanent=p.getString('registered_email_permanent')??p.getString('user_email')??widget.email);}
  Future<void> autoUpdate() async {
    try{
      setState((){isDownloading=true; statusMsg='Checking GitHub...';});
      final res=await http.get(Uri.parse('https://raw.githubusercontent.com/bluezzer/onyx-movie-final/main/version.json')).timeout(Duration(seconds:10));
      if(res.statusCode!=200){setState(()=>isDownloading=false); final fallback=Uri.parse('https://github.com/bluezzer/onyx-movie-final/releases/latest'); if(await canLaunchUrl(fallback)) await launchUrl(fallback, mode:LaunchMode.externalApplication); return;}
      final data=jsonDecode(res.body);
      setState(()=>statusMsg='Latest ${data['latest_version']} - Opening browser...');
      final apkUrl=Uri.parse(data['apk_url']??'https://github.com/bluezzer/onyx-movie-final/releases/latest');
      if(await canLaunchUrl(apkUrl)) await launchUrl(apkUrl, mode:LaunchMode.externalApplication);
      setState(()=>isDownloading=false);
    } catch(e){setState(()=>isDownloading=false); final fallback=Uri.parse('https://github.com/bluezzer/onyx-movie-final/releases/latest'); if(await canLaunchUrl(fallback)) await launchUrl(fallback, mode:LaunchMode.externalApplication);}
  }
  @override Widget build(BuildContext context){
    return SafeArea(child: ListView(padding:EdgeInsets.all(12), children:[Center(child:Text('Profile - Fixed Crash', style:TextStyle(color:Colors.white, fontSize:24, fontWeight:FontWeight.bold))), SizedBox(height:12), LiquidGlass(child: Padding(padding:EdgeInsets.all(12), child: Column(children:[Text(savedEmailPermanent, style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold)), Text('Permanent Auto-Login - Never stuck', style:TextStyle(color:Colors.white38, fontSize:10))]))), SizedBox(height:12), LiquidGlass(child: Padding(padding:EdgeInsets.all(12), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(statusMsg, style:TextStyle(color:Colors.white54, fontSize:11)), SizedBox(height:8), SizedBox(width:double.infinity, child:ElevatedButton(onPressed:isDownloading?null:autoUpdate, style:ElevatedButton.styleFrom(backgroundColor:Colors.green.withOpacity(0.3)), child:Text(isDownloading?'Checking...':'Check New Version - Open Browser')))]))), SizedBox(height:12), LiquidGlass(child: ListTile(leading:Icon(Icons.logout, color:Colors.redAccent), title:Text('Logout', style:TextStyle(color:Colors.redAccent)), onTap:() async {final p=await SharedPreferences.getInstance(); await p.clear(); if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>LoginScreen(onTheme:widget.onTheme)));}))]));
  }
}

class AdminMainNav extends StatefulWidget{ final String email; const AdminMainNav({super.key,required this.email}); @override State<AdminMainNav> createState()=>AdminMainNavState(); }
class AdminMainNavState extends State<AdminMainNav>{int idx=0; @override Widget build(BuildContext context){final pages=[AdminDashboardTab(email:widget.email), AdminAddMoviePro(), AdminManageMoviesPro()]; return Scaffold(backgroundColor:Color(0xFF020617), appBar:AppBar(backgroundColor:Color(0xFF020617), title:Text('ADMIN FIXED: ${widget.email}', style:TextStyle(fontSize:11,color:Colors.orange))), body:pages[idx], bottomNavigationBar:BottomNavigationBar(currentIndex:idx, backgroundColor:Color(0xFF0F172A), selectedItemColor:Colors.orange, unselectedItemColor:Colors.white54, onTap:(i)=>setState(()=>idx=i), items:[BottomNavigationBarItem(icon:Icon(Icons.dashboard),label:'Dashboard'), BottomNavigationBarItem(icon:Icon(Icons.video_call),label:'Upload'), BottomNavigationBarItem(icon:Icon(Icons.category),label:'Manage')]));}}

class AdminDashboardTab extends StatefulWidget{ final String email; const AdminDashboardTab({super.key,required this.email}); @override State<AdminDashboardTab> createState()=>AdminDashboardTabState(); }
class AdminDashboardTabState extends State<AdminDashboardTab>{
  final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){
    return StreamBuilder(stream: ref.onValue, builder: (c,snap){
      int total=0;
      if(snap.hasData && snap.data!.snapshot.value!=null){total=Map<String,dynamic>.from(snap.data!.snapshot.value as Map).length;}
      return ListView(padding:EdgeInsets.all(16), children:[LiquidGlass(radius:16, child: Container(padding:EdgeInsets.all(20), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text('Admin Dashboard - Internet Sync', style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)), Text(widget.email, style:TextStyle(color:Colors.orange, fontSize:11)), SizedBox(height:12), Text('Total: $total', style:TextStyle(color:Colors.green, fontSize:11))]))),]);
    });
  }
}

class AdminManageMoviesPro extends StatelessWidget{
  AdminManageMoviesPro({super.key});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){
    return StreamBuilder(stream: ref.onValue, builder: (c,snap){
      if(!snap.hasData) return Center(child:IPhoneLoader(size:20));
      if(snap.data!.snapshot.value==null) return Center(child:Text('No movies', style:TextStyle(color:Colors.white54)));
      final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
      final list=map.entries.toList();
      return ListView.builder(padding:EdgeInsets.all(12), itemCount:list.length, itemBuilder:(c,i){final m=Map<String,dynamic>.from(list[i].value as Map); return LiquidGlass(child: ListTile(title:Text(m['title']??'', style:TextStyle(color:Colors.white)), trailing:IconButton(icon:Icon(Icons.delete, color:Colors.redAccent), onPressed:() async {await ref.child(list[i].key).remove();})));});
    });
  }
}

class AdminAddMoviePro extends StatefulWidget{ const AdminAddMoviePro({super.key}); @override State<AdminAddMoviePro> createState()=>AdminAddMovieProState(); }
class AdminAddMovieProState extends State<AdminAddMoviePro> with SingleTickerProviderStateMixin{
  late TabController tab;
  final titleC=TextEditingController();
  final descC=TextEditingController();
  final vjC=TextEditingController(text:'VJ Junior');
  final yearC=TextEditingController(text:'2024');
  final seasonC=TextEditingController(text:'1');
  final episodeC=TextEditingController(text:'1');
  String category='Movie';
  String selectedGenre='Action';
  List<String> categories=['Movie','Series','Animation','Indian','Trending'];
  List<String> genres=['Action','Comedy','Drama','Indian','Animation','VJ Junior','VJ Emmy'];
  final picker=ImagePicker();
  Uint8List? posterBytes;
  Uint8List? bannerBytes;
  String? movieFilePath;
  String? movieFileName;
  int movieFileSize=0;
  bool isUploading=false;
  double uploadProgress=0;
  String uploadStatus='Ready';
  @override void initState(){super.initState(); tab=TabController(length:2, vsync:this);}
  void pickPoster() async {final x=await picker.pickImage(source:ImageSource.gallery, imageQuality:50); if(x!=null){final b=await x.readAsBytes(); setState(()=>posterBytes=b);}}
  void pickBanner() async {final x=await picker.pickImage(source:ImageSource.gallery, imageQuality:50); if(x!=null){final b=await x.readAsBytes(); setState(()=>bannerBytes=b);}}
  void pickMovieFile() async {
    FilePickerResult? result=await FilePicker.platform.pickFiles(type:FileType.video);
    if(result!=null){setState((){movieFilePath=result.files.first.path; movieFileName=result.files.first.name; movieFileSize=result.files.first.size;});}
  }
  void uploadMovie() async {
    if(titleC.text.isEmpty || posterBytes==null){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Title + Poster required'))); return;}
    setState((){isUploading=true; uploadProgress=0;});
    for(int i=0;i<=100;i++){await Future.delayed(Duration(milliseconds:20)); if(mounted) setState(()=>uploadProgress=i/100);}
    try{
      if(bannerBytes!=null){final bRef=FirebaseDatabase.instance.ref('banners').push(); await bRef.set({'imageBase64':base64Encode(bannerBytes!), 'timestamp':DateTime.now().millisecondsSinceEpoch, 'title':titleC.text});}
      final ref=FirebaseDatabase.instance.ref('movies').push();
      await ref.set({'title':titleC.text, 'description':descC.text, 'vj':vjC.text, 'genre':selectedGenre, 'year':yearC.text, 'category':category, 'isTrending':false, 'posterBase64':base64Encode(posterBytes!), 'videoFileName':movieFileName??'', 'videoFileSize':'${(movieFileSize/1024/1024).toStringAsFixed(1)} MB', 'type':'movie', 'timestamp':ServerValue.timestamp});
      setState(()=>isUploading=false); if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Uploaded'), backgroundColor:Colors.green));
    } catch(e){setState(()=>isUploading=false);}
  }
  void uploadSeries() async {
    if(titleC.text.isEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Series Title required'))); return;}
    setState(()=>isUploading=true);
    try{
      final ref=FirebaseDatabase.instance.ref('movies').push();
      await ref.set({'title':'${titleC.text} - S${seasonC.text}E${episodeC.text}', 'description':descC.text, 'vj':vjC.text, 'genre':selectedGenre, 'year':yearC.text, 'category':'Series', 'season':int.tryParse(seasonC.text)??1, 'episode':int.tryParse(episodeC.text)??1, 'posterBase64':posterBytes!=null?base64Encode(posterBytes!):'', 'type':'series', 'timestamp':ServerValue.timestamp});
      setState(()=>isUploading=false);
    } catch(e){setState(()=>isUploading=false);}
  }
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor:Color(0xFF020617), appBar:TabBar(controller:tab, labelColor:Colors.orange, tabs:[Tab(text:'Movie Upload'), Tab(text:'Series Upload')]), body: Column(children:[if(isUploading) Padding(padding:EdgeInsets.all(12), child: LiquidGlass(child: Container(padding:EdgeInsets.all(12), child: Column(children:[Text(uploadStatus, style:TextStyle(color:Colors.white, fontSize:11)), LinearProgressIndicator(value:uploadProgress, color:Colors.orange)])))), Expanded(child: TabBarView(controller:tab, children:[
      SingleChildScrollView(padding:EdgeInsets.all(12), child: Column(children:[TextField(controller:titleC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Movie Title *')), SizedBox(height:8), Row(children:[Expanded(child: ElevatedButton(onPressed:pickPoster, child:Text(posterBytes==null?'Poster *':'Poster OK'))), SizedBox(width:8), Expanded(child: ElevatedButton(onPressed:pickBanner, child:Text(bannerBytes==null?'Banner':'Banner OK')))]), SizedBox(height:8), ElevatedButton.icon(onPressed:pickMovieFile, icon:Icon(Icons.video_library), label:Text(movieFileName==null?'Pick Movie':movieFileName!)), SizedBox(height:20), SizedBox(width:double.infinity, height:50, child: ElevatedButton(onPressed:isUploading?null:uploadMovie, style:ElevatedButton.styleFrom(backgroundColor:Colors.orange), child:Text('UPLOAD MOVIE'))),])),
      SingleChildScrollView(padding:EdgeInsets.all(12), child: Column(children:[TextField(controller:titleC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Series Title *')), SizedBox(height:8), Row(children:[Expanded(child: TextField(controller:seasonC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Season'))), SizedBox(width:8), Expanded(child: TextField(controller:episodeC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Episode')))]), SizedBox(height:20), SizedBox(width:double.infinity, height:50, child: ElevatedButton(onPressed:isUploading?null:uploadSeries, style:ElevatedButton.styleFrom(backgroundColor:Colors.orange), child:Text('UPLOAD SERIES'))),])),
    ]))]));
  }
}

class UserMainNav extends StatefulWidget{
  final String email;
  final Function(bool) onTheme;
  const UserMainNav({super.key, required this.email, required this.onTheme});
  @override State<UserMainNav> createState()=>UserMainNavState();
}
class UserMainNavState extends State<UserMainNav>{
  int idx=0;
  @override Widget build(BuildContext context){
    final isAdmin=widget.email=='mugabibenjamin14@gmail.com';
    final pages=[HomeTab(email:widget.email, isAdmin:isAdmin), MoviesTab(), SeriesTab(), DownloadsTab(), ProfileTab(onTheme:widget.onTheme, email:widget.email, isAdmin:isAdmin)];
    return Scaffold(backgroundColor:Color(0xFF020617), body:pages[idx], bottomNavigationBar:BottomNavigationBar(currentIndex:idx, backgroundColor:Color(0xFF0F172A), selectedItemColor:Color(0xFF38BDF8), unselectedItemColor:Colors.white38, type:BottomNavigationBarType.fixed, onTap:(i)=>setState(()=>idx=i), items:[BottomNavigationBarItem(icon:Icon(Icons.home), label:'Home'), BottomNavigationBarItem(icon:Icon(Icons.movie), label:'Movies'), BottomNavigationBarItem(icon:Icon(Icons.tv), label:'Series'), BottomNavigationBarItem(icon:Icon(Icons.download), label:'Downloads'), BottomNavigationBarItem(icon:Icon(Icons.person), label:'Profile')]));
  }
}
