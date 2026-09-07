import 'dart:async'; import 'dart:convert'; import 'dart:io'; import 'dart:typed_data';
import 'package:file_picker/file_picker.dart'; import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'; import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try{ await Firebase.initializeApp().timeout(Duration(seconds:5)); } catch(e){ print('Firebase init skip: $e'); }
  runApp(OnyxApp());
}
class OnyxApp extends StatefulWidget{ const OnyxApp({super.key}); @override State<OnyxApp> createState()=>OnyxAppState(); }
class OnyxAppState extends State<OnyxApp>{ bool isDark=true; void toggle(bool d){setState(()=>isDark=d);} @override Widget build(BuildContext context){ return MaterialApp(debugShowCheckedModeBanner:false, theme:ThemeData.dark().copyWith(scaffoldBackgroundColor:Color(0xFF020617)), home:SplashScreen(onTheme:toggle)); } }
class SplashScreen extends StatefulWidget{ final Function(bool) onTheme; const SplashScreen({super.key, required this.onTheme}); @override State<SplashScreen> createState()=>SplashScreenState(); }
class SplashScreenState extends State<SplashScreen>{
  @override void initState(){super.initState(); check();}
  check() async {
    try{
      final p=await SharedPreferences.getInstance();
      await Future.delayed(Duration(seconds:2));
      final saved=p.getString('registered_email_permanent');
      final logged=p.getBool('is_logged_in')??false;
      if(saved!=null && logged){
        if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>UserMainNav(email:saved, isAdmin: p.getBool('is_admin')??false, onTheme:widget.onTheme)));
        return;
      }
    } catch(e){print(e);}
    if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>LoginScreen(onTheme:widget.onTheme)));
  }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor:Color(0xFF020617), body:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[Icon(Icons.movie, size:80, color:Colors.orange), SizedBox(height:10), Text('ONYX MOVIES', style:TextStyle(color:Colors.white, fontSize:22, fontWeight:FontWeight.bold)), SizedBox(height:20), CircularProgressIndicator(color:Colors.orange)]))); }
}
class LoginScreen extends StatefulWidget{ final Function(bool) onTheme; const LoginScreen({super.key, required this.onTheme}); @override State<LoginScreen> createState()=>LoginScreenState(); }
class LoginScreenState extends State<LoginScreen>{
  final emailC=TextEditingController(); final passC=TextEditingController();
  bool loading=false; String err='';
  void login() async {
    if(emailC.text.trim().isEmpty || passC.text.isEmpty){setState(()=>err='Enter email + pass'); return;}
    setState((){loading=true; err='';});
    try{
      final p=await SharedPreferences.getInstance();
      final email=emailC.text.trim().toLowerCase();
      final pass=passC.text;
      bool isAdmin=false;
      if(email=='mugabibenjamin14@gmail.com' && pass=='Mugabibe+-@1'){ isAdmin=true; }
      else if(pass.length<6){ throw 'Pass min 6 chars'; }
      await p.setString('registered_email_permanent', email);
      await p.setString('user_email', email);
      await p.setBool('is_logged_in', true);
      await p.setBool('is_admin', isAdmin);
      if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>UserMainNav(email:email, isAdmin:isAdmin, onTheme:widget.onTheme)));
    } catch(e){ setState(()=>err=e.toString()); }
    setState(()=>loading=false);
  }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor:Color(0xFF020617), body:Center(child:SingleChildScrollView(padding:EdgeInsets.all(20), child:Column(children:[Icon(Icons.movie, size:60, color:Colors.orange), SizedBox(height:12), Text('ONYX MOVIES LOGIN', style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)), SizedBox(height:20), TextField(controller:emailC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Email', filled:true, fillColor:Color(0xFF0F172A), border:OutlineInputBorder())), SizedBox(height:12), TextField(controller:passC, obscureText:true, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Password', filled:true, fillColor:Color(0xFF0F172A), border:OutlineInputBorder())), SizedBox(height:12), if(err.isNotEmpty) Text(err, style:TextStyle(color:Colors.red)), SizedBox(height:12), SizedBox(width:double.infinity, height:48, child:ElevatedButton(onPressed:loading?null:login, style:ElevatedButton.styleFrom(backgroundColor:Colors.orange), child:loading?CircularProgressIndicator(color:Colors.white):Text('LOGIN - SAVE FOREVER')))])))); }
}
class UserMainNav extends StatefulWidget{ final String email; final bool isAdmin; final Function(bool) onTheme; const UserMainNav({super.key, required this.email, required this.isAdmin, required this.onTheme}); @override State<UserMainNav> createState()=>UserMainNavState(); }
class UserMainNavState extends State<UserMainNav>{ int idx=0; @override Widget build(BuildContext context){ final pages=[HomeTabSimple(email:widget.email, isAdmin:widget.isAdmin), MoviesTabSimple(), SeriesTabSimple(), DownloadsTabSimple(), ProfileTabSimple(onTheme:widget.onTheme, email:widget.email, isAdmin:widget.isAdmin)]; return Scaffold(backgroundColor:Color(0xFF020617), body:pages[idx], bottomNavigationBar:BottomNavigationBar(currentIndex:idx, backgroundColor:Color(0xFF0F172A), selectedItemColor:Colors.orange, unselectedItemColor:Colors.white54, type:BottomNavigationBarType.fixed, onTap:(i)=>setState(()=>idx=i), items:[BottomNavigationBarItem(icon:Icon(Icons.home),label:'Home'), BottomNavigationBarItem(icon:Icon(Icons.movie),label:'Movies'), BottomNavigationBarItem(icon:Icon(Icons.tv),label:'Series'), BottomNavigationBarItem(icon:Icon(Icons.download),label:'Downloads'), BottomNavigationBarItem(icon:Icon(Icons.person),label:'Profile')])); } }
class HomeTabSimple extends StatelessWidget{
  final String email; final bool isAdmin;
  HomeTabSimple({super.key, required this.email, required this.isAdmin});
  final ref=FirebaseDatabase.instance.ref('movies');
  final bannerRef=FirebaseDatabase.instance.ref('banners');
  @override Widget build(BuildContext context){
    return SafeArea(child: CustomScrollView(slivers:[
      SliverToBoxAdapter(child: Padding(padding:EdgeInsets.all(12), child: Row(children:[Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text('ONYX MOVIES', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold, fontSize:20)), Text('Auto-login: $email', style:TextStyle(color:Colors.green, fontSize:10))])), if(isAdmin) ElevatedButton(onPressed:(){Navigator.push(context, MaterialPageRoute(builder:(_)=>AdminMainNav(email:email)));}, style:ElevatedButton.styleFrom(backgroundColor:Colors.orange), child:Text('ADMIN', style:TextStyle(fontSize:10)))]))),
      SliverToBoxAdapter(child: SizedBox(height:180, child: StreamBuilder(stream:bannerRef.orderByChild('timestamp').limitToLast(5).onValue, builder:(c,snap){
        if(!snap.hasData || snap.data!.snapshot.value==null) return Center(child:Text('No banners yet', style:TextStyle(color:Colors.white38)));
        final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
        final list=map.values.toList();
        return PageView.builder(itemCount:list.length, itemBuilder:(c,i){final b=Map<String,dynamic>.from(list[i] as Map); final img=b['imageBase64']??''; return Card(color:Color(0xFF1E293B), margin:EdgeInsets.all(8), child: img.isNotEmpty? ClipRRect(borderRadius:BorderRadius.circular(8), child: Image.memory(base64Decode(img), fit:BoxFit.cover, errorBuilder:(_,__,___)=>Center(child:Text(b['title']??'Banner', style:TextStyle(color:Colors.white)))) : Center(child:Text(b['title']??'Banner', style:TextStyle(color:Colors.white)))) ;});
      }))),
      SliverToBoxAdapter(child: Padding(padding:EdgeInsets.all(12), child: Text('All Movies - Tap to Play', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold)))),
      SliverToBoxAdapter(child: StreamBuilder(stream:ref.orderByChild('timestamp').onValue, builder:(c,snap){
        if(!snap.hasData) return Padding(padding:EdgeInsets.all(40), child:Center(child:CircularProgressIndicator(color:Colors.orange)));
        if(snap.data!.snapshot.value==null) return Padding(padding:EdgeInsets.all(40), child:Center(child:Text('No movies yet - Admin upload', style:TextStyle(color:Colors.white54))));
        final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
        final list=map.entries.toList()..sort((a,b){final at=Map<String,dynamic>.from(a.value as Map)['timestamp']??0; final bt=Map<String,dynamic>.from(b.value as Map)['timestamp']??0; return bt.compareTo(at);});
        return GridView.builder(shrinkWrap:true, physics:NeverScrollableScrollPhysics(), padding:EdgeInsets.all(8), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.68, crossAxisSpacing:8, mainAxisSpacing:8), itemCount:list.length, itemBuilder:(c,i){
          final m=Map<String,dynamic>.from(list[i].value as Map);
          final poster=m['posterBase64']??'';
          return GestureDetector(onTap:(){Navigator.push(context, MaterialPageRoute(builder:(_)=>DetailPageSimple(movie:m)));}, child: Card(color:Color(0xFF1E293B), child: Column(children:[Expanded(child: poster.isNotEmpty? ClipRRect(borderRadius:BorderRadius.vertical(top:Radius.circular(4)), child: Image.memory(base64Decode(poster), fit:BoxFit.cover, width:double.infinity, errorBuilder:(_,__,___)=>Icon(Icons.movie, color:Colors.white54))) : Icon(Icons.movie, color:Colors.white54, size:50)), Padding(padding:EdgeInsets.all(6), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(m['title']??'', maxLines:1, overflow:TextOverflow.ellipsis, style:TextStyle(color:Colors.white, fontSize:11, fontWeight:FontWeight.bold)), Text('${m['category']??''} • ${m['vj']??''}', maxLines:1, style:TextStyle(color:Colors.white54, fontSize:9))]))])));
        });
      })),
    ]));
  }
}
class MoviesTabSimple extends StatelessWidget{
  MoviesTabSimple({super.key});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){
    return SafeArea(child: Column(children:[Padding(padding:EdgeInsets.all(12), child: Text('Movies', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold))), Expanded(child: StreamBuilder(stream:ref.onValue, builder:(c,snap){
      if(!snap.hasData) return Center(child:CircularProgressIndicator());
      if(snap.data!.snapshot.value==null) return Center(child:Text('No movies', style:TextStyle(color:Colors.white54)));
      final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
      final list=map.entries.where((e){final m=Map<String,dynamic>.from(e.value as Map); return (m['type']??'movie')=='movie';}).toList();
      return GridView.builder(padding:EdgeInsets.all(8), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.7), itemCount:list.length, itemBuilder:(c,i){final m=Map<String,dynamic>.from(list[i].value as Map); return GestureDetector(onTap:(){Navigator.push(context, MaterialPageRoute(builder:(_)=>DetailPageSimple(movie:m)));}, child: Card(color:Color(0xFF1E293B), child:Column(children:[Expanded(child: m['posterBase64']!=null && m['posterBase64']!=''? Image.memory(base64Decode(m['posterBase64']), fit:BoxFit.cover, width:double.infinity) : Icon(Icons.movie)), Text(m['title']??'', style:TextStyle(color:Colors.white, fontSize:11))]))) ;});
    }))]));
  }
}
class SeriesTabSimple extends StatelessWidget{
  SeriesTabSimple({super.key});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){
    return SafeArea(child: Column(children:[Padding(padding:EdgeInsets.all(12), child: Text('Series', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold))), Expanded(child: StreamBuilder(stream:ref.onValue, builder:(c,snap){
      if(!snap.hasData) return Center(child:CircularProgressIndicator());
      if(snap.data!.snapshot.value==null) return Center(child:Text('No series', style:TextStyle(color:Colors.white54)));
      final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
      final list=map.entries.where((e){final m=Map<String,dynamic>.from(e.value as Map); return (m['type']??'')=='series';}).toList();
      return GridView.builder(padding:EdgeInsets.all(8), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.7), itemCount:list.length, itemBuilder:(c,i){final m=Map<String,dynamic>.from(list[i].value as Map); return Card(color:Color(0xFF1E293B), child:Column(children:[Expanded(child: Icon(Icons.tv, color:Colors.white54)), Text(m['title']??'', style:TextStyle(color:Colors.white, fontSize:11))]));});
    }))]));
  }
}
class DetailPageSimple extends StatelessWidget{
  final Map<String,dynamic> movie;
  const DetailPageSimple({super.key, required this.movie});
  @override Widget build(BuildContext context){
    final poster=movie['posterBase64']??'';
    return Scaffold(backgroundColor:Color(0xFF020617), appBar:AppBar(backgroundColor:Color(0xFF020617), title:Text(movie['title']??'', style:TextStyle(fontSize:13))), body:ListView(padding:EdgeInsets.all(12), children:[
      if(poster.isNotEmpty) ClipRRect(borderRadius:BorderRadius.circular(12), child: Image.memory(base64Decode(poster), height:300, width:double.infinity, fit:BoxFit.cover)),
      SizedBox(height:12), Text(movie['title']??'', style:TextStyle(color:Colors.white, fontSize:20, fontWeight:FontWeight.bold)),
      SizedBox(height:8), Text(movie['description']??'No description', style:TextStyle(color:Colors.white70)),
      SizedBox(height:12), SizedBox(width:double.infinity, height:50, child: ElevatedButton.icon(onPressed:() async { final p=await SharedPreferences.getInstance(); final list=p.getStringList('downloaded')??[]; list.add(jsonEncode({'title':movie['title']})); await p.setStringList('downloaded', list); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Saved to Downloads'), backgroundColor:Colors.green)); }, icon:Icon(Icons.download), label:Text('Save to Downloads'), style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF38BDF8)))),
    ]));
  }
}
class DownloadsTabSimple extends StatefulWidget{ const DownloadsTabSimple({super.key}); @override State<DownloadsTabSimple> createState()=>DownloadsTabSimpleState(); }
class DownloadsTabSimpleState extends State<DownloadsTabSimple>{
  List<Map<String,dynamic>> list=[];
  @override void initState(){super.initState(); load();}
  load() async {final p=await SharedPreferences.getInstance(); final d=p.getStringList('downloaded')??[]; setState(()=>list=d.map((e)=>jsonDecode(e)).toList().cast<Map<String,dynamic>>());}
  @override Widget build(BuildContext context){ return SafeArea(child: Column(children:[Padding(padding:EdgeInsets.all(12), child: Text('Downloads', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold))), Expanded(child: list.isEmpty? Center(child:Text('No downloads', style:TextStyle(color:Colors.white54))) : ListView.builder(itemCount:list.length, itemBuilder:(c,i){return Card(color:Color(0xFF1E293B), child:ListTile(title:Text(list[i]['title']??'', style:TextStyle(color:Colors.white))));}))])); }
}
class ProfileTabSimple extends StatefulWidget{
  final Function(bool) onTheme; final String email; final bool isAdmin;
  const ProfileTabSimple({super.key,required this.onTheme,required this.email,required this.isAdmin});
  @override State<ProfileTabSimple> createState()=>ProfileTabSimpleState();
}
class ProfileTabSimpleState extends State<ProfileTabSimple>{
  String status='Ready - Check version opens browser'; bool loading=false;
  Future<void> check() async {
    setState((){loading=true; status='Checking...';});
    try{
      final res=await http.get(Uri.parse('https://raw.githubusercontent.com/bluezzer/onyx-movie-final/main/version.json')).timeout(Duration(seconds:8));
      final data=jsonDecode(res.body);
      final url=Uri.parse(data['apk_url']??'https://github.com/bluezzer/onyx-movie-final/releases/latest');
      if(await canLaunchUrl(url)) await launchUrl(url, mode:LaunchMode.externalApplication);
      setState(()=>status='Opened ${data['latest_version']}');
    } catch(e){ final url=Uri.parse('https://github.com/bluezzer/onyx-movie-final/releases/latest'); if(await canLaunchUrl(url)) await launchUrl(url, mode:LaunchMode.externalApplication); }
    setState(()=>loading=false);
  }
  @override Widget build(BuildContext context){
    return SafeArea(child: ListView(padding:EdgeInsets.all(12), children:[
      Text('Profile - Login Saved Forever', textAlign:TextAlign.center, style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
      SizedBox(height:12), Card(color:Color(0xFF1E293B), child:Padding(padding:EdgeInsets.all(12), child:Column(children:[Text(widget.email, style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold)), Text('Permanent auto-login active', style:TextStyle(color:Colors.green, fontSize:11))]))),
      SizedBox(height:12), Card(color:Color(0xFF1E293B), child:Padding(padding:EdgeInsets.all(12), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(status, style:TextStyle(color:Colors.white54, fontSize:11)), SizedBox(height:8), SizedBox(width:double.infinity, child:ElevatedButton(onPressed:loading?null:check, style:ElevatedButton.styleFrom(backgroundColor:Colors.green), child:Text(loading?'Checking...':'Check New Version')))]))),
      SizedBox(height:12), Card(color:Color(0xFF1E293B), child:ListTile(leading:Icon(Icons.logout, color:Colors.red), title:Text('Logout - Clear Forever Login', style:TextStyle(color:Colors.red)), onTap:() async {final p=await SharedPreferences.getInstance(); await p.clear(); if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>LoginScreen(onTheme:widget.onTheme)));})),
    ]));
  }
}
class AdminMainNav extends StatefulWidget{ final String email; const AdminMainNav({super.key,required this.email}); @override State<AdminMainNav> createState()=>AdminMainNavState(); }
class AdminMainNavState extends State<AdminMainNav>{int idx=0; @override Widget build(BuildContext context){final pages=[AdminDashboardSimple(email:widget.email), AdminAddMoviePro(), AdminManageSimple()]; return Scaffold(backgroundColor:Color(0xFF020617), appBar:AppBar(backgroundColor:Color(0xFF020617), title:Text('ADMIN: ${widget.email}', style:TextStyle(fontSize:11,color:Colors.orange))), body:pages[idx], bottomNavigationBar:BottomNavigationBar(currentIndex:idx, backgroundColor:Color(0xFF0F172A), selectedItemColor:Colors.orange, unselectedItemColor:Colors.white54, onTap:(i)=>setState(()=>idx=i), items:[BottomNavigationBarItem(icon:Icon(Icons.dashboard),label:'Dash'), BottomNavigationBarItem(icon:Icon(Icons.video_call),label:'Upload'), BottomNavigationBarItem(icon:Icon(Icons.category),label:'Manage')]));}}
class AdminDashboardSimple extends StatelessWidget{
  final String email; AdminDashboardSimple({super.key,required this.email});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){ return StreamBuilder(stream:ref.onValue, builder:(c,snap){int total=0; if(snap.hasData && snap.data!.snapshot.value!=null) total=Map<String,dynamic>.from(snap.data!.snapshot.value as Map).length; return ListView(padding:EdgeInsets.all(16), children:[Card(color:Color(0xFF1E293B), child:Padding(padding:EdgeInsets.all(20), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text('Dashboard', style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)), Text(email, style:TextStyle(color:Colors.orange, fontSize:11)), Text('Total Movies: $total', style:TextStyle(color:Colors.green))])))]);});}
}
class AdminManageSimple extends StatelessWidget{
  AdminManageSimple({super.key}); final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){ return StreamBuilder(stream:ref.onValue, builder:(c,snap){ if(!snap.hasData) return Center(child:CircularProgressIndicator()); if(snap.data!.snapshot.value==null) return Center(child:Text('No movies', style:TextStyle(color:Colors.white54))); final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map); final list=map.entries.toList(); return ListView.builder(padding:EdgeInsets.all(12), itemCount:list.length, itemBuilder:(c,i){final m=Map<String,dynamic>.from(list[i].value as Map); return Card(color:Color(0xFF1E293B), child:ListTile(title:Text(m['title']??'', style:TextStyle(color:Colors.white)), trailing:IconButton(icon:Icon(Icons.delete, color:Colors.red), onPressed:() async {await ref.child(list[i].key).remove();})));});});}
}
class AdminAddMoviePro extends StatefulWidget{ const AdminAddMoviePro({super.key}); @override State<AdminAddMoviePro> createState()=>AdminAddMovieProState(); }
class AdminAddMovieProState extends State<AdminAddMoviePro> with SingleTickerProviderStateMixin{
  late TabController tab; final titleC=TextEditingController(); final descC=TextEditingController(); final vjC=TextEditingController(text:'VJ Junior'); final yearC=TextEditingController(text:'2024'); final seasonC=TextEditingController(text:'1'); final episodeC=TextEditingController(text:'1');
  String category='Movie'; String selectedGenre='Action'; List<String> categories=['Movie','Series','Animation','Indian','Trending']; List<String> genres=['Action','Comedy','Drama','Indian','Animation','VJ Junior','VJ Emmy'];
  final picker=ImagePicker(); Uint8List? posterBytes; Uint8List? bannerBytes; String? movieFileName; int movieFileSize=0; bool isUploading=false; double prog=0;
  void pickPoster() async {final x=await picker.pickImage(source:ImageSource.gallery, imageQuality:40); if(x!=null){final b=await x.readAsBytes(); setState(()=>posterBytes=b);}}
  void pickBanner() async {final x=await picker.pickImage(source:ImageSource.gallery, imageQuality:40); if(x!=null){final b=await x.readAsBytes(); setState(()=>bannerBytes=b);}}
  void pickMovie() async {FilePickerResult? r=await FilePicker.platform.pickFiles(type:FileType.video); if(r!=null) setState((){movieFileName=r.files.first.name; movieFileSize=r.files.first.size;});}
  void uploadMovie() async { if(titleC.text.isEmpty || posterBytes==null){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Title + Poster needed'))); return;} setState((){isUploading=true; prog=0;}); for(int i=0;i<=100;i++){await Future.delayed(Duration(milliseconds:15)); if(mounted) setState(()=>prog=i/100);} try{ if(bannerBytes!=null){final bRef=FirebaseDatabase.instance.ref('banners').push(); await bRef.set({'imageBase64':base64Encode(bannerBytes!), 'timestamp':DateTime.now().millisecondsSinceEpoch, 'title':titleC.text});} final ref=FirebaseDatabase.instance.ref('movies').push(); await ref.set({'title':titleC.text, 'description':descC.text, 'vj':vjC.text, 'genre':selectedGenre, 'year':yearC.text, 'category':category, 'posterBase64':base64Encode(posterBytes!), 'videoFileName':movieFileName??'', 'videoFileSize':'${(movieFileSize/1024/1024).toStringAsFixed(1)} MB', 'type':'movie', 'timestamp':ServerValue.timestamp}); setState(()=>isUploading=false); if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Movie Uploaded'), backgroundColor:Colors.green)); } catch(e){setState(()=>isUploading=false);} }
  void uploadSeries() async { if(titleC.text.isEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Title needed'))); return;} setState(()=>isUploading=true); try{ final ref=FirebaseDatabase.instance.ref('movies').push(); await ref.set({'title':'${titleC.text} - S${seasonC.text}E${episodeC.text}', 'description':descC.text, 'vj':vjC.text, 'genre':selectedGenre, 'year':yearC.text, 'category':'Series', 'season':int.tryParse(seasonC.text)??1, 'episode':int.tryParse(episodeC.text)??1, 'posterBase64':posterBytes!=null?base64Encode(posterBytes!):'', 'type':'series', 'timestamp':ServerValue.timestamp}); setState(()=>isUploading=false); } catch(e){setState(()=>isUploading=false);} }
  @override void initState(){super.initState(); tab=TabController(length:2, vsync:this);}
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor:Color(0xFF020617), appBar:TabBar(controller:tab, labelColor:Colors.orange, tabs:[Tab(text:'Movie'), Tab(text:'Series')]), body:Column(children:[if(isUploading) LinearProgressIndicator(value:prog, color:Colors.orange), Expanded(child:TabBarView(controller:tab, children:[SingleChildScrollView(padding:EdgeInsets.all(12), child:Column(children:[TextField(controller:titleC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Title *')), SizedBox(height:8), Row(children:[Expanded(child:ElevatedButton(onPressed:pickPoster, child:Text(posterBytes==null?'Poster *':'Poster OK'))), SizedBox(width:8), Expanded(child:ElevatedButton(onPressed:pickBanner, child:Text(bannerBytes==null?'Banner':'Banner OK')))]), SizedBox(height:8), ElevatedButton.icon(onPressed:pickMovie, icon:Icon(Icons.video_library), label:Text(movieFileName??'Pick Video')), SizedBox(height:20), SizedBox(width:double.infinity, height:50, child:ElevatedButton(onPressed:isUploading?null:uploadMovie, style:ElevatedButton.styleFrom(backgroundColor:Colors.orange), child:Text('UPLOAD MOVIE')))] )), SingleChildScrollView(padding:EdgeInsets.all(12), child:Column(children:[TextField(controller:titleC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Series Title *')), SizedBox(height:8), Row(children:[Expanded(child:TextField(controller:seasonC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Season'))), SizedBox(width:8), Expanded(child:TextField(controller:episodeC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:'Episode
