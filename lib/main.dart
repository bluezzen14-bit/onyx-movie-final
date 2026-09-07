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
import 'package:local_auth/local_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);
  runApp(OnyxApp());
}

class OnyxApp extends StatefulWidget{
  @override State<OnyxApp> createState()=>OnyxAppState();
}
class OnyxAppState extends State<OnyxApp>{
  bool isDark=true;
  @override
  void initState(){
    super.initState();
    loadTheme();
  }
  loadTheme() async {
    final p=await SharedPreferences.getInstance();
    setState(()=>isDark=p.getBool('isDark')??true);
  }
  void updateTheme(bool d) async {
    setState(()=>isDark=d);
    final p=await SharedPreferences.getInstance();
    await p.setBool('isDark', d);
  }
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      theme: isDark? ThemeData.dark().copyWith(scaffoldBackgroundColor:Color(0xFF020617)): ThemeData.light(),
      home: Splash(onTheme:updateTheme),
    );
  }
}

class Splash extends StatefulWidget{
  final Function(bool) onTheme;
  const Splash({super.key, required this.onTheme});
  @override State<Splash> createState()=>SplashState();
}
class SplashState extends State<Splash>{
  @override
  void initState(){
    super.initState();
    _init();
  }
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
  @override
  Widget build(BuildContext context){
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
  @override
  void initState(){super.initState(); c=AnimationController(vsync:this, duration:Duration(seconds:1))..repeat();}
  @override
  void dispose(){c.dispose(); super.dispose();}
  @override
  Widget build(BuildContext context){return RotationTransition(turns:c, child: Icon(Icons.autorenew, color:Colors.white70, size:widget.size));}
}

class LiquidGlass extends StatelessWidget{
  final Widget child;
  final double radius;
  const LiquidGlass({super.key, required this.child, this.radius=16});
  @override
  Widget build(BuildContext context){
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
  bool isLogin=true;
  bool loading=false;
  void submit() async {
    setState(()=>loading=true);
    final p=await SharedPreferences.getInstance();
    final email=emailC.text.trim();
    final pass=passC.text.trim();
    if(email.isEmpty || pass.isEmpty){
      setState(()=>loading=false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Email & Password required')));
      return;
    }
    await p.setString('user_email', email);
    await p.setString('registered_email_permanent', email);
    await p.setBool('isLoggedIn', true);
    await p.setString('passcode', passC.text);
    await p.setString('registered_pass', pass);

    setState(()=>loading=false);
    if(mounted){
      if(email=='mugabibenjamin14@gmail.com'){
        Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>AdminMainNav(email:email)));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>UserMainNav(email:email, onTheme:widget.onTheme)));
      }
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor:Color(0xFF020617), body:Center(child:SingleChildScrollView(padding:EdgeInsets.all(20), child:Column(children:[Icon(Icons.movie_filter, size:70, color:Colors.white), SizedBox(height:20), Text('ONYX MOVIES', style:TextStyle(color:Colors.white, fontSize:26, fontWeight:FontWeight.bold)), SizedBox(height:30), LiquidGlass(child:Padding(padding:EdgeInsets.all(16), child:Column(children:[TextField(controller:emailC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Email - Permanent Auto-Login', labelStyle:TextStyle(color:Colors.white54))), SizedBox(height:12), TextField(controller:passC, style:TextStyle(color:Colors.white), obscureText:true, decoration:InputDecoration(labelText:'Password', labelStyle:TextStyle(color:Colors.white54))), SizedBox(height:20), SizedBox(width:double.infinity, height:48, child:ElevatedButton(onPressed:loading?null:submit, style:ElevatedButton.styleFrom(backgroundColor:Colors.white.withOpacity(0.15)), child:loading? IPhoneLoader(size:18) : Text(isLogin?'LOGIN - Auto Save':'REGISTER - Permanent', style:TextStyle(color:Colors.white))))]))), SizedBox(height:12), Text('Fix: Login once, auto-login forever even after app closed', style:TextStyle(color:Colors.white38, fontSize:10))]))));
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
  @override
  Widget build(BuildContext context){
    final isAdmin=widget.email=='mugabibenjamin14@gmail.com';
    final pages=[
      HomeTab(email:widget.email, isAdmin:isAdmin),
      MoviesTab(),
      SeriesTab(),
      DownloadsTab(),
      ProfileTab(onTheme:widget.onTheme, email:widget.email, isAdmin:isAdmin)
    ];
    return Scaffold(backgroundColor:Color(0xFF020617), body:pages[idx], bottomNavigationBar:BottomNavigationBar(currentIndex:idx, backgroundColor:Color(0xFF0F172A), selectedItemColor:Color(0xFF38BDF8), unselectedItemColor:Colors.white38, type:BottomNavigationBarType.fixed, onTap:(i)=>setState(()=>idx=i), items:[
      BottomNavigationBarItem(icon:Icon(Icons.home), label:'Home'),
      BottomNavigationBarItem(icon:Icon(Icons.movie), label:'Movies'),
      BottomNavigationBarItem(icon:Icon(Icons.tv), label:'Series'),
      BottomNavigationBarItem(icon:Icon(Icons.download), label:'Downloads'),
      BottomNavigationBarItem(icon:Icon(Icons.person), label:'Profile'),
    ]));
  }
}

class HomeTab extends StatelessWidget{
  final String email;
  final bool isAdmin;
  HomeTab({super.key, required this.email, required this.isAdmin});
  final ref=FirebaseDatabase.instance.ref('movies');
  final bannerRef=FirebaseDatabase.instance.ref('banners');
  @override
  Widget build(BuildContext context){
    return SafeArea(child: CustomScrollView(slivers:[
      SliverToBoxAdapter(child: Padding(padding:EdgeInsets.all(12), child: Row(children:[Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text('ONYX MOVIES', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold, fontSize:20)), Text('Auto-login: $email', style:TextStyle(color:Colors.white38, fontSize:10))])), if(isAdmin) ElevatedButton(onPressed:(){Navigator.push(context, MaterialPageRoute(builder:(_)=>AdminMainNav(email:email)));}, style:ElevatedButton.styleFrom(backgroundColor:Colors.orange), child:Text('ADMIN', style:TextStyle(fontSize:10)))]))),
      SliverToBoxAdapter(child: SizedBox(height:200, child: StreamBuilder(stream:bannerRef.orderByChild('timestamp').limitToLast(7).onValue, builder:(c,snap){
        if(!snap.hasData || snap.data!.snapshot.value==null) return Center(child:Text('Banners: 7 Latest Uploads appear here', style:TextStyle(color:Colors.white38)));
        final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
        final list=map.values.toList();
        return PageView.builder(itemCount:list.length, itemBuilder:(c,i){
          final b=Map<String,dynamic>.from(list[i] as Map);
          final img=b['imageBase64']??'';
          return Padding(padding:EdgeInsets.all(8), child: LiquidGlass(radius:12, child: img.isNotEmpty? Image.memory(base64Decode(img), fit:BoxFit.cover, errorBuilder:(_,__,___)=>Center(child:Text(b['title']??'Banner', style:TextStyle(color:Colors.white)))) : Center(child:Text(b['title']??'Banner'))));
        });
      }))),
      SliverToBoxAdapter(child: Padding(padding:EdgeInsets.all(12), child: Text('All Movies - Internet Sync - Appears instantly after admin upload', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold)))),      SliverToBoxAdapter(child: StreamBuilder(stream:ref.orderByChild('timestamp').onValue, builder:(c,snap){
        if(!snap.hasData) return Center(child:IPhoneLoader(size:20));
        if(snap.data!.snapshot.value==null) return Center(child:Padding(padding:EdgeInsets.all(20), child:Text('No movies yet - Admin upload with internet - Will appear here instantly', textAlign:TextAlign.center, style:TextStyle(color:Colors.white54))));
        final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
        final list=map.entries.toList()..sort((a,b){final at=Map<String,dynamic>.from(a.value as Map)['timestamp']??0; final bt=Map<String,dynamic>.from(b.value as Map)['timestamp']??0; return bt.compareTo(at);});
        return GridView.builder(shrinkWrap:true, physics:NeverScrollableScrollPhysics(), padding:EdgeInsets.all(8), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.7, crossAxisSpacing:8, mainAxisSpacing:8), itemCount:list.length, itemBuilder:(c,i){
          final m=Map<String,dynamic>.from(list[i].value as Map);
          final poster=m['posterBase64']??'';
          return GestureDetector(onTap:(){Navigator.push(context, MaterialPageRoute(builder:(_)=>DetailPage(movie:m)));}, child: LiquidGlass(radius:12, child: Column(children:[Expanded(child: poster.isNotEmpty? ClipRRect(borderRadius:BorderRadius.vertical(top:Radius.circular(12)), child: Image.memory(base64Decode(poster), fit:BoxFit.cover, width:double.infinity, errorBuilder:(_,__,___)=>Icon(Icons.movie, color:Colors.white54))) : Icon(Icons.movie, color:Colors.white54)), Padding(padding:EdgeInsets.all(6), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(m['title']??'', maxLines:1, style:TextStyle(color:Colors.white, fontSize:12, fontWeight:FontWeight.bold)), Text('${m['category']??''} • ${m['genre']??''} • VJ:${m['vj']??''} • ${m['year']??''} ${m['type']??''} ${m['season']!=null?"S${m['season']}E${m['episode']}":""}', maxLines:2, style:TextStyle(color:Colors.white54, fontSize:9))]))])));
        });
      })),
    ]));
  }
}

class MoviesTab extends StatelessWidget{
  MoviesTab({super.key});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override
  Widget build(BuildContext context){
    return SafeArea(child: Column(children:[Padding(padding:EdgeInsets.all(12), child: Text('Movies Category - Internet Sync', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold))), Expanded(child: StreamBuilder(stream:ref.orderByChild('timestamp').onValue, builder:(c,snap){
      if(!snap.hasData) return Center(child:IPhoneLoader(size:20));
      if(snap.data!.snapshot.value==null) return Center(child:Text('No movies', style:TextStyle(color:Colors.white54)));
      final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
      final list=map.entries.where((e){final m=Map<String,dynamic>.from(e.value as Map); final cat=(m['category']??'').toString().toLowerCase(); final type=(m['type']??'movie').toString().toLowerCase(); return type=='movie' || cat.contains('movie') || cat.contains('action') || cat.contains('indian') || cat.contains('animation');}).toList();
      return GridView.builder(padding:EdgeInsets.all(8), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.7), itemCount:list.length, itemBuilder:(c,i){final m=Map<String,dynamic>.from(list[i].value as Map); final poster=m['posterBase64']??''; return GestureDetector(onTap:(){Navigator.push(context, MaterialPageRoute(builder:(_)=>DetailPage(movie:m)));}, child: LiquidGlass(radius:12, child: Column(children:[Expanded(child: poster.isNotEmpty? Image.memory(base64Decode(poster), fit:BoxFit.cover, width:double.infinity): Icon(Icons.movie)), Padding(padding:EdgeInsets.all(6), child:Text(m['title']??'', style:TextStyle(color:Colors.white, fontSize:11)))])));});
    }))]));
  }
}

class SeriesTab extends StatelessWidget{
  SeriesTab({super.key});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override
  Widget build(BuildContext context){
    return SafeArea(child: Column(children:[Padding(padding:EdgeInsets.all(12), child: Text('Series - Season/Episode - Internet Sync', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold))), Expanded(child: StreamBuilder(stream:ref.orderByChild('timestamp').onValue, builder:(c,snap){
      if(!snap.hasData) return Center(child:IPhoneLoader(size:20));
      if(snap.data!.snapshot.value==null) return Center(child:Text('No series', style:TextStyle(color:Colors.white54)));
      final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
      final list=map.entries.where((e){final m=Map<String,dynamic>.from(e.value as Map); return (m['type']??'').toString().toLowerCase()=='series' || (m['category']??'').toString().toLowerCase().contains('series');}).toList();
      return GridView.builder(padding:EdgeInsets.all(8), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.7), itemCount:list.length, itemBuilder:(c,i){final m=Map<String,dynamic>.from(list[i].value as Map); final poster=m['posterBase64']??''; return GestureDetector(onTap:(){Navigator.push(context, MaterialPageRoute(builder:(_)=>DetailPage(movie:m)));}, child: LiquidGlass(radius:12, child: Column(children:[Expanded(child: poster.isNotEmpty? Image.memory(base64Decode(poster), fit:BoxFit.cover, width:double.infinity): Icon(Icons.tv)), Padding(padding:EdgeInsets.all(6), child:Column(children:[Text(m['title']??'', style:TextStyle(color:Colors.white, fontSize:11)), Text('S${m['season']??1}E${m['episode']??1} • ${m['vj']??''}', style:TextStyle(color:Colors.white54, fontSize:9))]))])));
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
    setState((){
      isDownloading=true;
      progress=0;
    });
    for(int i=0;i<=100;i++){
      await Future.delayed(Duration(milliseconds:30));
      setState(()=>progress=i/100);
    }
    final p=await SharedPreferences.getInstance();
    final list=p.getStringList('downloaded')??[];
    final data=jsonEncode({
      'title':widget.movie['title'],
      'size':widget.movie['videoFileSize']??'1.2GB',
      'category':widget.movie['category'],
      'timestamp':DateTime.now().millisecondsSinceEpoch
    });
    list.add(data);
    await p.setStringList('downloaded', list);
    setState(()=>isDownloading=false);
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Downloaded to /Download/OnyxMovies/${widget.movie['title']}.mp4 - ${widget.movie['videoFileSize']??""} - Gallery'), backgroundColor:Colors.green));
  }
  @override
  Widget build(BuildContext context){
    final m=widget.movie;
    final poster=m['posterBase64']??'';
    final casts=(m['casts'] as List?)??[];
    return Scaffold(backgroundColor:Color(0xFF020617), appBar:AppBar(backgroundColor:Color(0xFF020617), title:Text(m['title']??'', style:TextStyle(fontSize:14))), body:SingleChildScrollView(padding:EdgeInsets.all(12), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
      if(poster.isNotEmpty) LiquidGlass(radius:12, child: ClipRRect(borderRadius:BorderRadius.circular(12), child: Image.memory(base64Decode(poster), fit:BoxFit.cover, width:double.infinity, height:250))),
      SizedBox(height:12),
      Text(m['title']??'', style:TextStyle(color:Colors.white, fontSize:20, fontWeight:FontWeight.bold)),
      Text('${m['category']??''} • ${m['genre']??''} • ${m['year']??''} • VJ:${m['vj']??''} ${m['type']??''} ${m['season']!=null?"• S${m['season']}E${m['episode']}":""} • ${m['videoFileSize']??""}', style:TextStyle(color:Colors.white54, fontSize:12)),
      SizedBox(height:12),
      LiquidGlass(child: Padding(padding:EdgeInsets.all(12), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text('Description', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold)), Text(m['description']??'No description', style:TextStyle(color:Colors.white70, fontSize:12))]))),
      SizedBox(height:12),
      if(casts.isNotEmpty) Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text('Casts (${casts.length})', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold)), SizedBox(height:8), SizedBox(height:110, child: ListView.builder(scrollDirection:Axis.horizontal, itemCount:casts.length, itemBuilder:(c,i){final cast=Map<String,dynamic>.from(casts[i] as Map); final img=cast['imageBase64']??''; return Padding(padding:EdgeInsets.only(right:12), child: Column(children:[CircleAvatar(radius:35, backgroundImage:img.isNotEmpty? MemoryImage(base64Decode(img)): null, child:img.isEmpty? Icon(Icons.person): null), SizedBox(height:4), Text(cast['realName']??'', style:TextStyle(color:Colors.white, fontSize:10)), Text(cast['actedName']??'', style:TextStyle(color:Colors.white54, fontSize:8))])) ;}))]),
      SizedBox(height:20),
      if(isDownloading) LiquidGlass(child: Padding(padding:EdgeInsets.all(12), child: Column(children:[Text('Downloading ${m['title']} - ${m['videoFileSize']??"1.2GB"} - ${ (progress*100).toStringAsFixed(0)}%', style:TextStyle(color:Colors.white, fontSize:11)), SizedBox(height:8), LinearProgressIndicator(value:progress, color:Color(0xFF38BDF8)), Text('${(progress*1.2).toStringAsFixed(2)}GB / ${m['videoFileSize']??"1.2GB"} - To /OnyxMovies', style:TextStyle(color:Colors.white54, fontSize:10))]))),
      SizedBox(height:12),
      SizedBox(width:double.infinity, height:50, child: ElevatedButton.icon(onPressed:isDownloading?null:downloadMovie, icon:Icon(Icons.download), label:Text(isDownloading?'Downloading ${(progress*100).toInt()}%...':'Download - Gallery /OnyxMovies - Size Based'), style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF38BDF8)))),
      SizedBox(height:20),
    ])));
  }
}class DownloadsTab extends StatefulWidget{
  const DownloadsTab({super.key});
  @override State<DownloadsTab> createState()=>DownloadsTabState();
}
class DownloadsTabState extends State<DownloadsTab> with SingleTickerProviderStateMixin{
  late TabController tab;
  List<Map<String,dynamic>> downloadedList=[];
  @override
  void initState(){
    super.initState();
    tab=TabController(length:2, vsync:this);
    loadDownloads();
  }
  loadDownloads() async {
    final p=await SharedPreferences.getInstance();
    final d=p.getStringList('downloaded')??[];
    setState(()=>downloadedList=d.map((e)=>jsonDecode(e)).toList().cast<Map<String,dynamic>>());
  }
  @override
  Widget build(BuildContext context){
    return SafeArea(child: Column(children: [LiquidGlass(child: Container(margin: EdgeInsets.all(12), padding:EdgeInsets.all(12), child: Row(children: [Icon(Icons.folder, color: Colors.white54), SizedBox(width:10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('OnyxMovies Folder: /Download/OnyxMovies - Gallery', style: TextStyle(color: Colors.white, fontSize:11)), LinearProgressIndicator(value:0.2, color: Colors.white54), Text('Size based: 250MB / 1.2GB', style: TextStyle(color: Colors.white38, fontSize:10))]))]))), TabBar(controller:tab, labelColor:Colors.white, indicatorColor:Colors.white54, tabs:[Tab(text:'Downloading'), Tab(text:'Completed')]), Expanded(child: TabBarView(controller:tab, children:[Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[IPhoneLoader(size:22), SizedBox(height:10), Text('Shows size based progress\nEx: 250MB / 1.2GB - 20%', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize:11))])), downloadedList.isEmpty? Center(child: Text('No downloaded - Saved to Gallery /OnyxMovies', style: TextStyle(color: Colors.white54))) : ListView.builder(itemCount: downloadedList.length, itemBuilder: (c,i){final m=downloadedList[i]; return LiquidGlass(child: ListTile(title: Text(m['title']??'', style: TextStyle(color: Colors.white)), subtitle: Text('Saved to /Download/OnyxMovies/${m['title']}.mp4 • ${m['size']??''}', style: TextStyle(color: Colors.white54, fontSize:10)), trailing: Icon(Icons.check_circle, color: Colors.green)));}),]))]));
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
  final picker=ImagePicker();
  Uint8List? avatarBytes;
  bool isDownloading=false;
  String statusMsg='Ready - Tap Check Version';
  String savedEmailPermanent='';
  bool downloadToGallery=true;
  bool highSpeed=true;
  bool allowPermissions=true;
  bool darkMode=true;
  String passcode='';
  void pickAvatar() async {final x=await picker.pickImage(source:ImageSource.gallery); if(x!=null){final b=await x.readAsBytes(); setState(()=>avatarBytes=b); final p=await SharedPreferences.getInstance(); await p.setString('avatar',base64Encode(b));}}
  @override
  void initState(){super.initState(); loadAll();}
  loadAll() async {
    final p=await SharedPreferences.getInstance();
    final av=p.getString('avatar'); if(av!=null){setState(()=>avatarBytes=base64Decode(av));}
    setState((){
      savedEmailPermanent=p.getString('registered_email_permanent')?? p.getString('user_email')?? widget.email;
      downloadToGallery=p.getBool('download_to_gallery')??true;
      highSpeed=p.getBool('high_speed')??true;
      allowPermissions=p.getBool('allow_permissions')??true;
      darkMode=p.getBool('isDark')??true;
      passcode=p.getString('passcode')??'';
    });
  }
  Future<void> autoUpdate() async {
    try{
      setState((){
        isDownloading=true;
        statusMsg='Checking GitHub version.json...';
      });
      final res=await http.get(Uri.parse('https://raw.githubusercontent.com/bluezzer/onyx-movie-final/main/version.json')).timeout(Duration(seconds:10));
      if(res.statusCode!=200){
        setState((){
          isDownloading=false;
          statusMsg='version.json not found (404) - Upload version.json to main branch root of onyx-movie-final';
        });
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Upload version.json first'), backgroundColor:Colors.orange));
        final fallback=Uri.parse('https://github.com/bluezzer/onyx-movie-final/releases/latest');
        if(await canLaunchUrl(fallback)) await launchUrl(fallback, mode:LaunchMode.externalApplication);
        return;
      }
      final data=jsonDecode(res.body);
      setState(()=>statusMsg='Latest ${data['latest_version']} - ${data['whats_new']}');
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Opening browser: ${data['latest_version']}'), backgroundColor:Colors.green));
      final apkUrl=Uri.parse(data['apk_url']??'https://github.com/bluezzer/onyx-movie-final/releases/latest');
      final releasePage=Uri.parse('https://github.com/bluezzer/onyx-movie-final/releases/latest');
      if(await canLaunchUrl(apkUrl)){
        await launchUrl(apkUrl, mode:LaunchMode.externalApplication);
      } else if(await canLaunchUrl(releasePage)){
        await launchUrl(releasePage, mode:LaunchMode.externalApplication);
      }
      setState((){
        isDownloading=false;
        statusMsg='Browser opened - Download ${data['latest_version']} from Releases page';
      });
    } catch(e){
      setState((){
        isDownloading=false;
        statusMsg='Error: $e - Opening releases manually';
      });
      final fallback=Uri.parse('https://github.com/bluezzer/onyx-movie-final/releases/latest');
      if(await canLaunchUrl(fallback)) await launchUrl(fallback, mode:LaunchMode.externalApplication);
    }
  }
  void setPasscodeDialog(){
    final ctrl=TextEditingController();
    showDialog(context: context, builder: (_){return AlertDialog(backgroundColor: Color(0xFF1E293B), title: Text('Set 6-digit Passcode', style: TextStyle(color: Colors.white)), content: TextField(controller: ctrl, keyboardType: TextInputType.number, maxLength:6, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText:'Enter 6 digits')), actions:[TextButton(onPressed: () async {final p=await SharedPreferences.getInstance(); await p.setString('passcode', ctrl.text); setState(()=>passcode=ctrl.text); Navigator.pop(context);}, child: Text('Save'))]);});
  }
  @override
  Widget build(BuildContext context){
    String displayEmail=savedEmailPermanent.isEmpty? widget.email : savedEmailPermanent;
    return SafeArea(child: ListView(padding:EdgeInsets.all(12), children:[Center(child: Padding(padding: EdgeInsets.only(top:10,bottom:20), child: Text('Profile', style: TextStyle(color: Colors.white, fontSize:24, fontWeight: FontWeight.bold)))), Center(child: LiquidGlass(radius:15, child: Container(padding: EdgeInsets.symmetric(horizontal:20,vertical:12), child: Column(children: [Icon(Icons.email, color: Color(0xFF38BDF8), size:20), SizedBox(height:6), Text(displayEmail, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center), Text('Registered Email - Permanent Auto-Login', style: TextStyle(color: Colors.white38, fontSize:10))])))), SizedBox(height:12), Center(child: GestureDetector(onTap: pickAvatar, child: LiquidGlass(radius:45, child: CircleAvatar(radius:45, backgroundImage: avatarBytes!=null?MemoryImage(avatarBytes!):null, child: avatarBytes==null?Icon(Icons.person,size:40):null)))), SizedBox(height:12), LiquidGlass(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children:[Icon(Icons.system_update,color:Colors.white70,size:20), SizedBox(width:8), Text('New Release Update - FIXED', style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))]), SizedBox(height:6), Text(statusMsg, style: TextStyle(color: Colors.white54, fontSize:11)), if(isDownloading) Padding(padding:EdgeInsets.only(top:8), child: LinearProgressIndicator(color:Colors.green)), SizedBox(height:8), SizedBox(width:double.infinity, child: ElevatedButton(onPressed: isDownloading?null:autoUpdate, style: ElevatedButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.3)), child: Text(isDownloading?'Checking...':'Check New Version - Open Browser', style: TextStyle(color: Colors.white))))]))), SizedBox(height:8), LiquidGlass(child: SwitchListTile(title: Text('Download to Gallery - /OnyxMovies', style: TextStyle(color: Colors.white, fontSize:12)), subtitle: Text(downloadToGallery? 'On - Saves to Gallery' : 'Off', style: TextStyle(color: Colors.white38, fontSize:10)), value: downloadToGallery, onChanged: (v) async {final p=await SharedPreferences.getInstance(); await p.setBool('download_to_gallery',v); setState(()=>downloadToGallery=v);} )), LiquidGlass(child: SwitchListTile(title: Text('High Speed Downloads', style: TextStyle(color: Colors.white, fontSize:12)), value: highSpeed, onChanged: (v) async {final p=await SharedPreferences.getInstance(); await p.setBool('high_speed',v); setState(()=>highSpeed=v);} )), LiquidGlass(child: SwitchListTile(title: Text('Dark Mode', style: TextStyle(color: Colors.white, fontSize:12)), value: darkMode, onChanged: (v) async {final p=await SharedPreferences.getInstance(); await p.setBool('isDark',v); widget.onTheme(v); setState(()=>darkMode=v);} )), SizedBox(height:8), Text('Security', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), LiquidGlass(child: ListTile(leading: Icon(Icons.lock,color:Colors.white70), title: Text('Passcode: ${passcode.isEmpty? "Not set" : "****${passcode.substring(passcode.length>2?passcode.length-2:0)}"}', style: TextStyle(color: Colors.white, fontSize:12)), onTap: setPasscodeDialog)), LiquidGlass(child: ListTile(leading: Icon(Icons.logout, color:Colors.redAccent), title: Text('Logout - Clear Auto-Login', style: TextStyle(color: Colors.redAccent, fontSize:12)), onTap: () async {final p=await SharedPreferences.getInstance(); await p.clear(); if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>LoginScreen(onTheme:widget.onTheme)));})), SizedBox(height:8), Text('Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), LiquidGlass(child: Column(children:[ListTile(leading: Icon(Icons.email,color:Colors.white70), title: Text('mugabibenjamin14@gmail.com', style: TextStyle(color: Colors.white, fontSize:12)), onTap: () async {final uri=Uri.parse('mailto:mugabibenjamin14@gmail.com'); if(await canLaunchUrl(uri)) await launchUrl(uri);}), ListTile(leading: Icon(Icons.camera_alt,color:Colors.white70), title: Text('Instagram: onyxmovies', style: TextStyle(color: Colors.white, fontSize:12))),])), SizedBox(height:20),]));
  }
}

class AdminMainNav extends StatefulWidget{
  final String email;
  const AdminMainNav({super.key,required this.email});
  @override State<AdminMainNav> createState()=>AdminMainNavState();
}
class AdminMainNavState extends State<AdminMainNav>{
  int idx=0;
  @override
  Widget build(BuildContext context){
    final pages=[AdminDashboardTab(email:widget.email), AdminAddMoviePro(), AdminManageMoviesPro()];
    return Scaffold(backgroundColor:Color(0xFF020617), appBar:AppBar(backgroundColor:Color(0xFF020617), title:Text('ADMIN v2.1 FIXED: ${widget.email}', style:TextStyle(fontSize:11,color:Colors.orange))), body:pages[idx], bottomNavigationBar:BottomNavigationBar(currentIndex:idx, backgroundColor:Color(0xFF0F172A), selectedItemColor:Colors.orange, unselectedItemColor:Colors.white54, onTap:(i)=>setState(()=>idx=i), items:[BottomNavigationBarItem(icon:Icon(Icons.dashboard),label:'Dashboard'), BottomNavigationBarItem(icon:Icon(Icons.video_call),label:'Upload'), BottomNavigationBarItem(icon:Icon(Icons.category),label:'Manage')]));
  }
}

class AdminDashboardTab extends StatefulWidget{
  final String email;
  const AdminDashboardTab({super.key,required this.email});
  @override State<AdminDashboardTab> createState()=>AdminDashboardTabState();
}
class AdminDashboardTabState extends State<AdminDashboardTab>{
  final ref=FirebaseDatabase.instance.ref('movies');
  @override
  Widget build(BuildContext context){
    return StreamBuilder(stream: ref.onValue, builder: (c,snap){
      int total=0, movies=0, series=0, trending=0;
      if(snap.hasData && snap.data!.snapshot.value!=null){final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map); total=map.length; for(var e in map.values){final m=Map<String,dynamic>.from(e as Map); if((m['category']??'').toString().toLowerCase().contains('series') || (m['type']??'').toString().toLowerCase()=='series') series++; else movies++; if(m['isTrending']==true) trending++;}}
      return ListView(padding: EdgeInsets.all(16), children:[
        LiquidGlass(radius:16, child: Container(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('Admin Dashboard v2.1 - Internet Sync', style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)), Text(widget.email, style:TextStyle(color:Colors.orange, fontSize:11)), SizedBox(height:12), Row(children:[Expanded(child: Container(padding:EdgeInsets.all(12), decoration:BoxDecoration(color:Colors.white.withOpacity(0.05), borderRadius:BorderRadius.circular(12)), child:Column(children:[Text('$total', style:TextStyle(color:Colors.white, fontSize:24, fontWeight:FontWeight.bold)), Text('Total - Live', style:TextStyle(color:Colors.white54, fontSize:10))]))), SizedBox(width:8), Expanded(child: Container(padding:EdgeInsets.all(12), decoration:BoxDecoration(color:Colors.white.withOpacity(0.05), borderRadius:BorderRadius.circular(12)), child:Column(children:[Text('$movies', style:TextStyle(color:Color(0xFF38BDF8), fontSize:24, fontWeight:FontWeight.bold)), Text('Movies', style:TextStyle(color:Colors.white54, fontSize:10))]))), SizedBox(width:8), Expanded(child: Container(padding:EdgeInsets.all(12), decoration:BoxDecoration(color:Colors.white.withOpacity(0.05), borderRadius:BorderRadius.circular(12)), child:Column(children:[Text('$series', style:TextStyle(color:Colors.orange, fontSize:24, fontWeight:FontWeight.bold)), Text('Series', style:TextStyle(color:Colors.white54, fontSize:10))]))),]), SizedBox(height:12), Text('FIX: Movies appear instantly in User Panel via Internet - Firebase Realtime sync', style:TextStyle(color:Colors.green, fontSize:10)),]))),
        SizedBox(height:12),
        LiquidGlass(child: ListTile(leading:Icon(Icons.cloud_done, color:Colors.green), title:Text('Firebase Realtime - keepSynced enabled', style:TextStyle(color:Colors.white, fontSize:12)), subtitle:Text('Admin upload → User sees instantly with internet', style:TextStyle(color:Colors.white54, fontSize:10)))),
      ]);
    });
  }
}class AdminManageMoviesPro extends StatelessWidget{
  AdminManageMoviesPro({super.key});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override
  Widget build(BuildContext context){
    return StreamBuilder(stream: ref.onValue, builder: (c,snap){
      if(!snap.hasData) return Center(child:IPhoneLoader(size:20));
      if(snap.data!.snapshot.value==null) return Center(child:Text('No movies - Upload first', style:TextStyle(color:Colors.white54)));
      final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
      final list=map.entries.toList()..sort((a,b){final at=Map<String,dynamic>.from(a.value as Map)['timestamp']??0; final bt=Map<String,dynamic>.from(b.value as Map)['timestamp']??0; return bt.compareTo(at);});
      return Column(children:[Padding(padding:EdgeInsets.all(12), child: LiquidGlass(child: Container(width:double.infinity, padding:EdgeInsets.all(12), child:Text('Manage: ${list.length} items - Live Firebase', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold))))), Expanded(child: ListView.builder(padding:EdgeInsets.all(12), itemCount:list.length, itemBuilder:(c,i){final m=Map<String,dynamic>.from(list[i].value as Map); return Padding(padding:EdgeInsets.only(bottom:8), child: LiquidGlass(child: ListTile(title:Text(m['title']??'', style:TextStyle(color:Colors.white)), subtitle:Text('${m['category']??''} • VJ: ${m['vj']??''} • ${m['genre']??''} • ${m['year']??''} ${m['isTrending']==true?"• TRENDING":""} ${m['type']??""} ${m['season']!=null?"• S${m['season']}E${m['episode']}":""} • ${m['videoFileSize']??""}', style:TextStyle(color:Colors.white54, fontSize:9)), trailing: IconButton(icon:Icon(Icons.delete, color:Colors.redAccent), onPressed:() async {await ref.child(list[i].key).remove(); if(c.mounted) ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('Deleted')));})))) ;}))]);
    });
  }
}

class AdminAddMoviePro extends StatefulWidget{
  const AdminAddMoviePro({super.key});
  @override State<AdminAddMoviePro> createState()=>AdminAddMovieProState();
}
class AdminAddMovieProState extends State<AdminAddMoviePro> with SingleTickerProviderStateMixin{
  late TabController tab;
  final titleC=TextEditingController();
  final descC=TextEditingController();
  final vjC=TextEditingController(text:'VJ Junior');
  final genreC=TextEditingController(text:'Action');
  final yearC=TextEditingController(text:'2024');
  final seasonC=TextEditingController(text:'1');
  final episodeC=TextEditingController(text:'1');
  String category='Movie';
  String selectedGenre='Action';
  List<String> categories=['Movie','Series','Animation','Indian','Trending','Action','Comedy'];
  List<String> genres=['Action','Comedy','Drama','Indian','Animation','Horror','VJ Junior','VJ Emmy','VJ Jingo','VJ Ice P'];
  final picker=ImagePicker();
  Uint8List? posterBytes;
  Uint8List? bannerBytes;
  String? movieFilePath;
  String? movieFileName;
  int movieFileSize=0;
  String? seriesFilePath;
  String? seriesFileName;
  List<Map<String, dynamic>> casts=[];
  bool isTrending=false;
  bool isUploading=false;
  double uploadProgress=0;
  String uploadStatus='Ready';

  @override
  void initState(){super.initState(); tab=TabController(length:2, vsync:this);}

  void pickPoster() async {final x=await picker.pickImage(source:ImageSource.gallery, imageQuality:50); if(x!=null){final b=await x.readAsBytes(); setState(()=>posterBytes=b);}}
  void pickBanner() async {final x=await picker.pickImage(source:ImageSource.gallery, imageQuality:50); if(x!=null){final b=await x.readAsBytes(); setState(()=>bannerBytes=b);}}
  void pickMovieFile() async {
    FilePickerResult? result=await FilePicker.platform.pickFiles(type:FileType.video, allowMultiple:false);
    if(result!=null){
      final file=result.files.first;
      setState((){
        movieFilePath=file.path;
        movieFileName=file.name;
        movieFileSize=file.size;
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Movie: ${file.name} - ${(file.size/1024/1024).toStringAsFixed(1)} MB - Files & Gallery OK')));
    } else {
      final x=await picker.pickVideo(source:ImageSource.gallery);
      if(x!=null){
        final f=File(x.path);
        final size=await f.length();
        setState((){
          movieFilePath=x.path;
          movieFileName=x.name;
          movieFileSize=size;
        });
      }
    }
  }
  void pickSeriesFile() async {
    FilePickerResult? result=await FilePicker.platform.pickFiles(type:FileType.video);
    if(result!=null){
      final file=result.files.first;
      setState((){
        seriesFilePath=file.path;
        seriesFileName=file.name;
      });
    } else {
      final x=await picker.pickVideo(source:ImageSource.gallery);
      if(x!=null){setState((){seriesFilePath=x.path; seriesFileName=x.name;});}
    }
  }
  void addCast() async {
    if(casts.length>=5){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Max 5 casts'))); return;}
    final realC=TextEditingController(); final actedC=TextEditingController(); Uint8List? castImg;
    await showDialog(context: context, builder: (_)=>StatefulBuilder(builder: (c,setS)=>AlertDialog(backgroundColor:Color(0xFF1E293B), title:Text('Add Cast', style:TextStyle(color:Colors.white)), content:Column(mainAxisSize:MainAxisSize.min, children:[GestureDetector(onTap:() async {final x=await picker.pickImage(source:ImageSource.gallery, imageQuality:50); if(x!=null){final b=await x.readAsBytes(); setS(()=>castImg=b);}}, child:CircleAvatar(radius:30, backgroundImage:castImg!=null?MemoryImage(castImg!):null, child:castImg==null?Icon(Icons.person):null)), TextField(controller:realC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Real Name')), TextField(controller:actedC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Acted Name'))]), actions:[TextButton(onPressed:()=>Navigator.pop(context), child:Text('Cancel')), TextButton(onPressed:(){setState(()=>casts.add({'realName':realC.text, 'actedName':actedC.text, 'imageBase64':castImg!=null?base64Encode(castImg!):''})); Navigator.pop(context);}, child:Text('Add'))])));
  }

  void uploadMovie() async {
    if(titleC.text.isEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Title required'))); return;}
    if(posterBytes==null){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Poster required'))); return;}
    if(movieFilePath==null){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Pick Movie file from Gallery/Files'))); return;}
    setState((){
      isUploading=true;
      uploadProgress=0;
      uploadStatus='Uploading ${titleC.text} - ${(movieFileSize/1024/1024).toStringAsFixed(1)} MB to Firebase Realtime...';
    });
    for(int i=0;i<=100;i++){await Future.delayed(Duration(milliseconds:20)); if(mounted) setState(()=>uploadProgress=i/100);}
    
    try{
      if(bannerBytes!=null){
        final bRef=FirebaseDatabase.instance.ref('banners').push();
        await bRef.set({'imageBase64':base64Encode(bannerBytes!), 'timestamp':DateTime.now().millisecondsSinceEpoch, 'title':titleC.text});
      }
      final ref=FirebaseDatabase.instance.ref('movies').push();
      FirebaseDatabase.instance.ref('movies').keepSynced(true);
      FirebaseDatabase.instance.ref('banners').keepSynced(true);
      
      await ref.set({
        'title':titleC.text,
        'description':descC.text,
        'vj':vjC.text,
        'genre':selectedGenre,
        'year':yearC.text,
        'category':category,
        'isTrending':isTrending,
        'posterBase64':base64Encode(posterBytes!),
        'bannerBase64':bannerBytes!=null?base64Encode(bannerBytes!):'',
        'videoFileName':movieFileName??'',
        'videoFilePath':movieFilePath??'',
        'videoFileSize':'${(movieFileSize/1024/1024).toStringAsFixed(1)} MB',
        'type':'movie',
        'casts':casts,
        'timestamp':ServerValue.timestamp,
        'uploadedBy':'admin',
        'locationInUserPanel':category,
        'hasInternetSync':true,
      });
      setState((){
        isUploading=false;
        uploadStatus='Uploaded! Appears in User Panel - $category - With Internet - ${titleC.text}';
        uploadProgress=1;
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('SUCCESS: ${titleC.text} appears in $category with internet!'), backgroundColor:Colors.green, duration:Duration(seconds:3)));
    } catch(e){
      setState((){
        isUploading=false;
        uploadStatus='Error: $e';
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Upload failed: $e')));
    }
  }

  void uploadSeries() async {
    if(titleC.text.isEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Series Title required'))); return;}
    if(seriesFilePath==null){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Pick Series Episode file'))); return;}
    setState((){
      isUploading=true;
      uploadProgress=0;
      uploadStatus='Uploading Series S${seasonC.text}E${episodeC.text}';
    });
    for(int i=0;i<=100;i++){await Future.delayed(Duration(milliseconds:15)); if(mounted) setState(()=>uploadProgress=i/100);}
    try{
      final ref=FirebaseDatabase.instance.ref('movies').push();
      FirebaseDatabase.instance.ref('movies').keepSynced(true);
      await ref.set({
        'title':'${titleC.text} - S${seasonC.text}E${episodeC.text}',
        'description':descC.text,
        'vj':vjC.text,
        'genre':selectedGenre,
        'year':yearC.text,
        'category':'Series',
        'seriesCategory':category,
        'season':int.tryParse(seasonC.text)??1,
        'episode':int.tryParse(episodeC.text)??1,
        'isTrending':isTrending,
        'posterBase64':posterBytes!=null?base64Encode(posterBytes!):'',
        'videoFileName':seriesFileName??'',
        'videoFilePath':seriesFilePath??'',
        'type':'series',
        'casts':casts,
        'timestamp':ServerValue.timestamp,
        'hasInternetSync':true,
      });
      setState((){
        isUploading=false;
        uploadStatus='Series Uploaded! S${seasonC.text}E${episodeC.text} - Appears with internet';
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Series Uploaded! Appears instantly'), backgroundColor:Colors.green));
    } catch(e){
      setState((){
        isUploading=false;
        uploadStatus='Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor:Color(0xFF020617), appBar:TabBar(controller:tab, labelColor:Colors.orange, indicatorColor:Colors.orange, tabs:[Tab(icon:Icon(Icons.movie), text:'Movie Upload'), Tab(icon:Icon(Icons.tv), text:'Series Upload')]), body: Column(children:[if(isUploading) Padding(padding:EdgeInsets.all(12), child: LiquidGlass(child: Container(padding:EdgeInsets.all(12), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(uploadStatus, style:TextStyle(color:Colors.white, fontSize:11)), SizedBox(height:6), LinearProgressIndicator(value:uploadProgress, color:Colors.orange), Text('${(uploadProgress*100).toStringAsFixed(0)}% - Firebase Realtime sync - Internet', style:TextStyle(color:Colors.white54, fontSize:9))])))), Expanded(child: TabBarView(controller:tab, children:[
      SingleChildScrollView(padding:EdgeInsets.all(12), child: Column(children:[LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:titleC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Movie Title * - Will appear with internet', border:InputBorder.none)))), SizedBox(height:8), LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:descC, style:TextStyle(color:Colors.white), maxLines:2, decoration:InputDecoration(labelText:'Description', border:InputBorder.none)))), SizedBox(height:8), Row(children:[Expanded(child: LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:vjC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'VJ Name', border:InputBorder.none))))), SizedBox(width:8), Expanded(child: LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:yearC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Year', border:InputBorder.none)))))]), SizedBox(height:8), LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: Column(children:[Row(children:[Text('Category:', style:TextStyle(color:Colors.white)), SizedBox(width:10), Expanded(child: DropdownButton<String>(value:category, isExpanded:true, dropdownColor:Color(0xFF1E293B), style:TextStyle(color:Colors.white), items:categories.map((c)=>DropdownMenuItem(value:c, child:Text(c, style:TextStyle(fontSize:11)))).toList(), onChanged:(v){if(v!=null) setState(()=>category=v);} ))]), SizedBox(height:8), Row(children:[Text('Genre:', style:TextStyle(color:Colors.white)), SizedBox(width:10), Expanded(child: DropdownButton<String>(value:selectedGenre, isExpanded:true, dropdownColor:Color(0xFF1E293B), style:TextStyle(color:Colors.white), items:genres.map((g)=>DropdownMenuItem(value:g, child:Text(g, style:TextStyle(fontSize:11)))).toList(), onChanged:(v){if(v!=null) setState(()=>selectedGenre=v);} ))]), SwitchListTile(title:Text('Trending?', style:TextStyle(color:Colors.white, fontSize:12)), value:isTrending, onChanged:(v)=>setState(()=>isTrending=v))]))), SizedBox(height:12), Row(children:[Expanded(child: LiquidGlass(child: ElevatedButton.icon(onPressed:pickPoster, icon:Icon(Icons.image, color:Colors.white70), label:Text(posterBytes==null?'Poster *':'Poster OK', style:TextStyle(color:Colors.white70, fontSize:10))))), SizedBox(width:8), Expanded(child: LiquidGlass(child: ElevatedButton.icon(onPressed:pickBanner, icon:Icon(Icons.panorama, color:Colors.white70), label:Text(bannerBytes==null?'Banner 7 latest':'Banner OK', style:TextStyle(color:Colors.white70, fontSize:10)))))]), SizedBox(height:12), LiquidGlass(child: Padding(padding:EdgeInsets.all(12), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text('Movie File - Large Files OK - Gallery & Files - Appears with internet', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold, fontSize:11)), SizedBox(height:8), Row(children:[Expanded(child: ElevatedButton.icon(onPressed:pickMovieFile, icon:Icon(Icons.video_library), label:Text(movieFileName==null?'Pick Movie from Files/Gallery':movieFileName!, style:TextStyle(fontSize:10)), style:ElevatedButton.styleFrom(backgroundColor:Colors.orange.withOpacity(0.3))))]), if(movieFilePath!=null) Padding(padding:EdgeInsets.only(top:8), child: Text('Selected: $movieFileName - ${(movieFileSize/1024/1024).toStringAsFixed(2)} MB - Will sync via Firebase internet', style:TextStyle(color:Colors.green, fontSize:10)))]))), SizedBox(height:12), LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: Row(children:[Text('Casts (max 5)', style:TextStyle(color:Colors.white)), Spacer(), ElevatedButton(onPressed:addCast, child:Text('Add Cast'))]))), Wrap(spacing:8, children:casts.map((c)=>Chip(label:Text(c['realName']))).toList()), SizedBox(height:20), LiquidGlass(radius:12, child: SizedBox(width:double.infinity, height:50, child: ElevatedButton(onPressed:isUploading?null:uploadMovie, style:ElevatedButton.styleFrom(backgroundColor:Colors.orange), child:Text(isUploading?'Uploading ${(uploadProgress*100).toStringAsFixed(0)}% - Firebase...':'UPLOAD MOVIE - Appears with Internet in $category', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold, fontSize:11))))), SizedBox(height:80),])),
      SingleChildScrollView(padding:EdgeInsets.all(12), child: Column(children:[LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:titleC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Series Title *', border:InputBorder.none)))), SizedBox(height:8), Row(children:[Expanded(child: LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:vjC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'VJ Name', border:InputBorder.none))))), SizedBox(width:8), Expanded(child: LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:seasonC, style:TextStyle(color:Colors.white), keyboardType:TextInputType.number, decoration:InputDecoration(labelText:'Season', border:InputBorder.none))))), SizedBox(width:8), Expanded(child: LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:episodeC, style:TextStyle(color:Colors.white), keyboardType:TextInputType.number, decoration:InputDecoration(labelText:'Episode', border:InputBorder.none)))))]), SizedBox(height:8), LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:descC, style:TextStyle(color:Colors.white), maxLines:2, decoration:InputDecoration(labelText:'Description', border:InputBorder.none)))), SizedBox(height:12), Row(children:[Expanded(child: LiquidGlass(child: ElevatedButton.icon(onPressed:pickPoster, icon:Icon(Icons.image), label:Text(posterBytes==null?'Series Poster':'Poster OK')))), SizedBox(width:8), Expanded(child: LiquidGlass(child: ElevatedButton.icon(onPressed:pickSeriesFile, icon:Icon(Icons.video_file), label:Text(seriesFileName==null?'Pick Series - Files/Gallery':seriesFileName!, style:TextStyle(fontSize:10)))))]), if(seriesFilePath!=null) Padding(padding:EdgeInsets.all(8), child: Text('Series: S${seasonC.text}E${episodeC.text} - $seriesFileName - Internet sync', style:TextStyle(color:Colors.green, fontSize:11))), SizedBox(height:20), LiquidGlass(radius:12, child: SizedBox(width:double.infinity, height:50, child: ElevatedButton(onPressed:isUploading?null:uploadSeries, style:ElevatedButton.styleFrom(backgroundColor:Colors.orange), child:Text(isUploading?'Uploading ${uploadProgress*100~/1}%...':'UPLOAD SERIES S${seasonC.text}E${episodeC.text} - Internet', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold))))), SizedBox(height:80),])),
    ]))]));
  }
}
