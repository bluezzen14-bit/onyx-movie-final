import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
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
      child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        RotationTransition(
          turns: _controller,
          child: CustomPaint(size: Size(widget.size, widget.size), painter: _IOSSpinnerPainter(color: Colors.white.withOpacity(0.5))),
        ),
        if(widget.text!=null) Padding(padding: EdgeInsets.only(top: 10), child: Text(widget.text!, style: TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center)),
      ]),
    );
  }
}
class _IOSSpinnerPainter extends CustomPainter {
  final Color color;
  _IOSSpinnerPainter({required this.color});
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
    setState(()=>loading=false);
    if(!mounted)return;
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
  final ref=FirebaseDatabase.instance.ref('movies');final bannerRef=FirebaseDatabase.instance.ref('banners');String q="";
  @override Widget build(BuildContext context){
    return SafeArea(child:Column(children:[Padding(padding:EdgeInsets.all(12),child:Row(children:[Expanded(child:LiquidGlass(radius:25, child: Container(height:50, child:TextField(onChanged:(v)=>setState(()=>q=v.toLowerCase()),style:TextStyle(color:Colors.white),decoration:InputDecoration(hintText:"Search VJ, Genre...",prefixIcon:Icon(Icons.search,color:Colors.white54),border:InputBorder.none))))),SizedBox(width:10),LiquidGlass(radius:15, child: Container(height:50,width:50, child:Icon(Icons.notifications_none,color:Colors.white54))) ])),Expanded(child:StreamBuilder(stream:ref.onValue,builder:(c,snap){if(!snap.hasData){return IPhoneLoader(size:22, text:"Loading...");}List<MapEntry> all=[];if(snap.data!.snapshot.value!=null){final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);all=map.entries.toList();}return SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[StreamBuilder(stream:bannerRef.onValue,builder:(c,bSnap){String? b64;if(bSnap.hasData&&bSnap.data!.snapshot.value!=null){final map=Map<String,dynamic>.from(bSnap.data!.snapshot.value as Map);if(map.isNotEmpty){b64=Map<String,dynamic>.from(map.entries.first.value as Map)['imageBase64'];}}return Container(margin: EdgeInsets.all(12), height: 180, decoration: BoxDecoration(color: Color(0xFF112233), borderRadius: BorderRadius.circular(25)), child: b64!=null&&b64.length>100? ClipRRect(borderRadius:BorderRadius.circular(25),child:Image.memory(base64Decode(b64.split(',').last),fit:BoxFit.cover,width:double.infinity)) : Center(child: IPhoneLoader(size: 24, text: "Banner 7 Latest - iPhone loading small transparent")),);}),Padding(padding:EdgeInsets.all(12),child:Text("Latest Release",style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold))),]));}))]));
  }
}
class MoviesTab extends StatelessWidget{
  MoviesTab({super.key});final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){
    return SafeArea(child:Column(children:[Padding(padding:EdgeInsets.all(12),child:LiquidGlass(radius:12, child: Container(width:double.infinity,padding:EdgeInsets.all(12),child:Text("Movies Page - iOS 26 Transparent Glass",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:16))))),Expanded(child:StreamBuilder(stream: ref.onValue, builder: (c, snap) {if (!snap.hasData) {return IPhoneLoader(size: 22, text: "Loading Movies...");}if (snap.data!.snapshot.value == null) {return Center(child: Text("No Movies", style: TextStyle(color: Colors.white54)));}final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);final list = map.entries.toList();return GridView.builder(padding: EdgeInsets.all(12), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: list.length, itemBuilder: (c, i) {final m = Map<String, dynamic>.from(list[i].value as Map);final poster = m['posterBase64']?? '';return GestureDetector(onTap: (){Navigator.push(c,MaterialPageRoute(builder: (_) => DetailPage(data: m, id: list[i].key)));}, child: LiquidGlass(radius:12, child: poster.toString().length > 100? Image.memory(base64Decode(poster.toString().split(',').last), fit: BoxFit.cover) : Icon(Icons.movie, color: Colors.white54)));});})),
    ]));
  }
}
class SeriesTab extends StatelessWidget{
  SeriesTab({super.key});final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){
    return SafeArea(child:Column(children:[Padding(padding:EdgeInsets.all(12),child:LiquidGlass(radius:12, child:Container(width:double.infinity,padding:EdgeInsets.all(12),child:Text("Series Page - iOS 26 Transparent Glass",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:16))))),Expanded(child:StreamBuilder(stream: ref.onValue, builder: (c, snap) {if (!snap.hasData) {return IPhoneLoader(size: 22, text: "Loading Series...");}if (snap.data!.snapshot.value == null) {return Center(child: Text("No Series", style: TextStyle(color: Colors.white54)));}final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);final list = map.entries.where((e) => (Map<String, dynamic>.from(e.value as Map)['category']?? '').toString().toLowerCase().contains('series')).toList();return GridView.builder(padding: EdgeInsets.all(12), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: list.length, itemBuilder: (c, i) {final m = Map<String, dynamic>.from(list[i].value as Map);final poster = m['posterBase64']?? '';return GestureDetector(onTap: (){Navigator.push(c,MaterialPageRoute(builder: (_) => DetailPage(data: m, id: list[i].key)));}, child: LiquidGlass(radius:12, child: poster.toString().length > 100? Image.memory(base64Decode(poster.toString().split(',').last), fit: BoxFit.cover) : Icon(Icons.tv, color: Colors.white54)));});})),
    ]));
  }
}
class DetailPage extends StatelessWidget{
  final Map<String, dynamic> data;final String id;const DetailPage({super.key,required this.data,required this.id});
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF020617), appBar: AppBar(backgroundColor: Color(0xFF020617), title: Text(data['title']?? '')), body: SingleChildScrollView(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [LiquidGlass(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text(data['title']?? '', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))])))])));
  }
}
class DownloadsTab extends StatefulWidget{const DownloadsTab({super.key});@override State<DownloadsTab> createState()=>DownloadsTabState();}
class DownloadsTabState extends State<DownloadsTab> with SingleTickerProviderStateMixin{
  late TabController tab;@override void initState(){super.initState();tab=TabController(length:2,vsync:this);}
  @override Widget build(BuildContext context){return SafeArea(child:Column(children:[TabBar(controller:tab,labelColor:Colors.white,indicatorColor:Colors.white54,tabs:[Tab(text:"Downloading"),Tab(text:"Completed")]),Expanded(child:TabBarView(controller:tab,children:[Center(child:IPhoneLoader(size:22)),Center(child:Text("No available download",style:TextStyle(color:Colors.white54)))]))]));
  }
}
class ProfileTab extends StatefulWidget{
  final Function(bool) onTheme;final String email;final bool isAdmin;
  const ProfileTab({super.key,required this.onTheme,required this.email,required this.isAdmin});
  @override State<ProfileTab> createState()=>ProfileTabState();
}
class ProfileTabState extends State<ProfileTab>{
  final picker=ImagePicker();Uint8List? avatarBytes;bool isDownloading=false;double progress=0;String statusMsg="Ready";String savedEmailPermanent="";
  void pickAvatar() async {final x=await picker.pickImage(source:ImageSource.gallery);if(x!=null){final b=await x.readAsBytes();setState(()=>avatarBytes=b);final p=await SharedPreferences.getInstance();await p.setString('avatar',base64Encode(b));}}
  @override void initState(){super.initState();loadAvatar();loadPermanentEmail();}
  void loadAvatar() async {final p=await SharedPreferences.getInstance();final av=p.getString('avatar');if(av!=null)setState(()=>avatarBytes=base64Decode(av));}
  void loadPermanentEmail() async {final p=await SharedPreferences.getInstance();setState(()=>savedEmailPermanent = p.getString('registered_email_permanent')?? p.getString('user_email')?? widget.email);}
  Future<void> autoUpdate() async {
    try{
      setState(()=>isDownloading=true);
      final res=await http.get(Uri.parse("https://raw.githubusercontent.com/bluezzer/onyx-movie-final/main/version.json"));
      if(res.statusCode!=200){setState(()=>isDownloading=false);return;}
      final data=jsonDecode(res.body);
      final dir=await getExternalStorageDirectory();
      final filePath="${dir!.path}/onyx_movie_${data['latest_version']}.apk";
      final file=File(filePath);
      final request=await http.Client().send(http.Request('GET', Uri.parse("https://github.com/bluezzer/onyx-movie-final/releases/latest/download/app-release.apk")));
      final sink=file.openWrite();
      await for(var chunk in request.stream){sink.add(chunk);}
      await sink.close();
      final uri=Uri.file(filePath);
      if(await canLaunchUrl(uri))await launchUrl(uri,mode:LaunchMode.externalApplication);
      setState(()=>isDownloading=false);
    } catch(e){setState(()=>isDownloading=false);}
  }
  @override Widget build(BuildContext context){
    String displayEmail = savedEmailPermanent.isEmpty? widget.email : savedEmailPermanent;
    return SafeArea(
      child: ListView(
        padding:EdgeInsets.all(12),
        children:[
          Center(child: Padding(padding: EdgeInsets.only(top: 10, bottom: 20), child: Text("Profile", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)))),
          Center(
            child: LiquidGlass(
              radius: 15,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    Icon(Icons.email, color: Color(0xFF38BDF8), size: 20),
                    SizedBox(height: 6),
                    Text(displayEmail, style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
                    Text("Permanently Saved", style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(child:GestureDetector(onTap:pickAvatar,child:LiquidGlass(radius:45, child: CircleAvatar(radius:45,backgroundImage:avatarBytes!=null?MemoryImage(avatarBytes!):null,child:avatarBytes==null?Icon(Icons.person,size:40):null)))),
          SizedBox(height:20),
          LiquidGlass(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children:[
                  Row(children:[Icon(Icons.system_update,color:Colors.white70,size:20),SizedBox(width:8),Text("Auto Update",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))]),
                  SizedBox(height:8),
                  Text(statusMsg,style:TextStyle(color:Colors.white54,fontSize:11)),
                  SizedBox(height:8),
                  SizedBox(width:double.infinity,child:ElevatedButton(onPressed:isDownloading?null:autoUpdate,style:ElevatedButton.styleFrom(backgroundColor:Colors.white.withOpacity(0.1)),child:Text(isDownloading?"Downloading...":"Check & Download Update",style:TextStyle(color:Colors.white)))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
  @override Widget build(BuildContext context){
    return ListView(padding: EdgeInsets.all(16), children: [LiquidGlass(radius:16, child: Container(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Admin Dashboard", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text(email, style: TextStyle(color: Colors.orange))]))),SizedBox(height: 16),LiquidGlass(radius:12, child: SizedBox(width:double.infinity, height:50, child: ElevatedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAddMovie()));}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.08)), child: Text("Add Banner + Movie", style: TextStyle(color: Colors.white))))),]);
  }
}
class AdminManageMovies extends StatelessWidget{
  AdminManageMovies({super.key});final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){
    return StreamBuilder(stream: ref.onValue, builder: (c, snap) {if (!snap.hasData) {return IPhoneLoader(size: 20);}if (snap.data!.snapshot.value == null) {return Center(child: Text("No movies", style: TextStyle(color: Colors.white54)));}final map = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);final list = map.entries.toList();return ListView.builder(padding: EdgeInsets.all(12), itemCount: list.length, itemBuilder: (c, i) {final m = Map<String, dynamic>.from(list[i].value as Map);final title = m['title']?? '';return Padding(padding: EdgeInsets.only(bottom:8), child: LiquidGlass(child: ListTile(title: Text(title, style: TextStyle(color: Colors.white)), trailing: IconButton(icon: Icon(Icons.delete, color: Colors.redAccent), onPressed: () async {await ref.child(list[i].key).remove();}))));});});
  }
}
class AdminAddMovie extends StatefulWidget{const AdminAddMovie({super.key});@override State<AdminAddMovie> createState()=>AdminAddMovieState();}
class AdminAddMovieState extends State<AdminAddMovie>{
  final titleC=TextEditingController();final descC=TextEditingController();final vjC=TextEditingController(text:"VJ Junior");final genreC=TextEditingController(text:"Action");String category="Movie";final picker=ImagePicker();Uint8List? posterBytes;Uint8List? bannerBytes;List<Map<String, dynamic>> casts=[];
  void pickPoster() async {final x=await picker.pickImage(source:ImageSource.gallery);if(x!=null){final b=await x.readAsBytes();setState(()=>posterBytes=b);}}
  void pickBanner() async {final x=await picker.pickImage(source:ImageSource.gallery);if(x!=null){final b=await x.readAsBytes();setState(()=>bannerBytes=b);}}
  void addCast() async {
    if(casts.length>=5){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Max 5 casts")));return;}
    final realC=TextEditingController();final actedC=TextEditingController();Uint8List? castImg;
    await showDialog(context: context, builder: (_) => StatefulBuilder(builder: (c, setS) => AlertDialog(backgroundColor: Color(0xFF1E293B), title: Text("Add Cast", style:TextStyle(color:Colors.white)), content: Column(mainAxisSize: MainAxisSize.min, children: [GestureDetector(onTap: () async {final x=await picker.pickImage(source: ImageSource.gallery);if(x!=null){final b=await x.readAsBytes();setS(()=>castImg=b);}}, child: CircleAvatar(radius:30,backgroundImage:castImg!=null?MemoryImage(castImg!):null,child:castImg==null?Icon(Icons.person):null)), TextField(controller:realC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:"Real Name")), TextField(controller:actedC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:"Acted Name"))]), actions: [TextButton(onPressed:()=>Navigator.pop(context),child:Text("Cancel")), TextButton(onPressed:(){setState(()=>casts.add({"realName":realC.text,"actedName":actedC.text,"imageBase64":castImg!=null?base64Encode(castImg!):""}));Navigator.pop(context);},child:Text("Add"))])));
  }
  void save() async {
    if(titleC.text.isEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Title required")));return;}
    if(bannerBytes!=null){final bRef=FirebaseDatabase.instance.ref('banners').push();await bRef.set({"imageBase64":base64Encode(bannerBytes!), "timestamp":DateTime.now().millisecondsSinceEpoch});}
    final ref=FirebaseDatabase.instance.ref('movies').push();
    await ref.set({"title":titleC.text, "description":descC.text, "vj":vjC.text, "genre":genreC.text, "category":category, "posterBase64":posterBytes!=null?base64Encode(posterBytes!):"", "casts":casts, "timestamp":DateTime.now().millisecondsSinceEpoch});
    if(mounted){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved!")));Navigator.pop(context);}
  }
  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFF020617),
      appBar: AppBar(backgroundColor: Color(0xFF020617), title:Text("ADMIN PRO: Add Movie")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:titleC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:"Movie Title *", border:InputBorder.none)))),
            SizedBox(height:8),
            LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:descC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:"Description", border:InputBorder.none)))),
            SizedBox(height:8),
            LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:vjC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:"VJ Name", border:InputBorder.none)))),
            SizedBox(height:8),
            LiquidGlass(child: Padding(padding:EdgeInsets.all(8), child: TextField(controller:genreC, style:TextStyle(color:Colors.white), decoration:InputDecoration(labelText:"Genre", border:InputBorder.none)))),
            SizedBox(height:12),
            LiquidGlass(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text("Category:", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: category,
                      dropdownColor: Color(0xFF1E293B),
                      style: TextStyle(color: Colors.white),
                      items: [
                        DropdownMenuItem(value: "Movie", child: Text("Movie")),
                        DropdownMenuItem(value: "Series", child: Text("Series")),
                      ],
                      onChanged: (v){
                        if(v!=null) setState(()=>category=v);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height:12),
            Row(
              children:[
                Expanded(child:LiquidGlass(child: ElevatedButton.icon(onPressed:pickPoster, icon:Icon(Icons.image,color:Colors.white70),label:Text(posterBytes==null?"Pick Poster":"Poster OK", style:TextStyle(color:Colors.white70))))),
                SizedBox(width:8),
                Expanded(child:LiquidGlass(child: ElevatedButton.icon(onPressed:pickBanner, icon:Icon(Icons.panorama,color:Colors.white70),label:Text(bannerBytes==null?"Pick Banner":"Banner OK", style:TextStyle(color:Colors.white70))))),
              ],
            ),
            SizedBox(height:12),
            LiquidGlass(
              child: Padding(
                padding:EdgeInsets.all(8),
                child: Row(
                  children:[
                    Text("Casts (max 5)", style:TextStyle(color:Colors.white)),
                    Spacer(),
                    ElevatedButton(onPressed:addCast,child:Text("Add Cast")),
                  ],
                ),
              ),
            ),
            Wrap(spacing:8,children:casts.map((c)=>Chip(label:Text(c['realName']))).toList()),
            SizedBox(height:20),
            LiquidGlass(
              radius:12,
              child: SizedBox(
                width:double.infinity,
                height:50,
                child:ElevatedButton(
                  onPressed:save,
                  style:ElevatedButton.styleFrom(backgroundColor:Colors.white.withOpacity(0.1)),
                  child:Text("Save to Firebase",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
