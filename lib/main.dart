import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptions(apiKey:"AIzaSyAqhqupsd2veboIOFZfIjaNNOKpKxlV2MI",authDomain:"onyx-movies-2b58b.firebaseapp.com",databaseURL:"https://onyx-movies-2b58b-default-rtdb.firebaseio.com",projectId:"onyx-movies-2b58b",storageBucket:"onyx-movies-2b58b.firebasestorage.app",messagingSenderId:"243702982500",appId:"1:243702982500:web:a65b9c59dd2e06c3ec7c71"));
  runApp(MyApp());
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
    if(isAdminMail&&admins[e]!=p){setState(()=>loading=false);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrong admin password"),backgroundColor: Colors.red));return;}
    await pref.setString('user_email',e);await pref.setBool('is_admin',isAdminMail);
    setState(()=>loading=false);
    if(!mounted)return;
    if(isAdminMail){Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>StartSelector(onTheme:widget.onTheme,email:e)));}
    else{Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>UserMainNav(onTheme:widget.onTheme,email:e,isAdmin:false)));}
  }
  @override Widget build(BuildContext context){return Scaffold(backgroundColor:Color(0xFF020617),body:SafeArea(child:Padding(padding:EdgeInsets.all(20),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.movie_filter,color:Color(0xFF38BDF8),size:70),Text("ONYX MOVIES",style:TextStyle(color:Colors.white,fontSize:26,fontWeight:FontWeight.bold)),SizedBox(height:20),TextField(controller:emailC,style:TextStyle(color:Colors.white),decoration:InputDecoration(labelText:"Email",filled:true,fillColor:Color(0xFF1E293B),border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide.none))),SizedBox(height:10),TextField(controller:passC,obscureText:true,style:TextStyle(color:Colors.white),decoration:InputDecoration(labelText:"Password",filled:true,fillColor:Color(0xFF1E293B),border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide.none))),SizedBox(height:20),SizedBox(width:double.infinity,height:50,child:ElevatedButton(onPressed:loading?null:doAuth,style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF38BDF8)),child:Text("REGISTER / LOGIN",style:TextStyle(color:Colors.black,fontWeight:FontWeight.bold)))),SizedBox(height:10),Text("Admin: mugabibenjamin14@gmail.com / Mugabibe+-@1",style:TextStyle(color:Colors.white24,fontSize:10)),Text("rachetyaz900@gmail.com / Akram2007",style:TextStyle(color:Colors.white24,fontSize:10))]))));}
}
class StartSelector extends StatelessWidget{
  final Function(bool) onTheme;final String email;
  const StartSelector({super.key,required this.onTheme,required this.email});
  @override Widget build(BuildContext context){return Scaffold(backgroundColor:Color(0xFF020617),body:Center(child:Padding(padding:EdgeInsets.all(20),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text("Admin: $email",style:TextStyle(color:Colors.orange)),SizedBox(height:20),GestureDetector(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>UserMainNav(onTheme:onTheme,email:email,isAdmin:true))),child:Container(height:120,decoration:BoxDecoration(color:Color(0xFF1E293B),borderRadius:BorderRadius.circular(20),border:Border.all(color:Color(0xFF38BDF8),width:2)),child:Center(child:Text("USER PANEL",style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold))))),SizedBox(height:16),GestureDetector(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AdminMainNav(email:email))),child:Container(height:120,decoration:BoxDecoration(color:Color(0xFF1E293B),borderRadius:BorderRadius.circular(20),border:Border.all(color:Colors.orange,width:2)),child:Center(child:Text("ADMIN PANEL",style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)))))]))));}
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
    return SafeArea(child:Column(children:[Padding(padding:EdgeInsets.all(12),child:Row(children:[Expanded(child:Container(height:50,decoration:BoxDecoration(color:Color(0xFF1E293B),borderRadius:BorderRadius.circular(25)),child:TextField(onChanged:(v)=>setState(()=>q=v.toLowerCase()),style:TextStyle(color:Colors.white),decoration:InputDecoration(hintText:"Search VJ, Genre...",prefixIcon:Icon(Icons.search,color:Color(0xFF38BDF8)),border:InputBorder.none)))),SizedBox(width:10),Container(height:50,width:50,decoration:BoxDecoration(color:Color(0xFF1E293B),borderRadius:BorderRadius.circular(15)),child:Icon(Icons.notifications_none,color:Colors.white))])),Expanded(child:StreamBuilder(stream:ref.onValue,builder:(c,snap){List<MapEntry> all=[];if(snap.hasData&&snap.data!.snapshot.value!=null){final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);all=map.entries.toList();}return SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[StreamBuilder(stream:bannerRef.onValue,builder:(c,bSnap){String? b64;if(bSnap.hasData&&bSnap.data!.snapshot.value!=null){final map=Map<String,dynamic>.from(bSnap.data!.snapshot.value as Map);if(map.isNotEmpty){b64=Map<String,dynamic>.from(map.entries.first.value as Map)['imageBase64'];}}return Container(height:180,margin:EdgeInsets.all(12),decoration:BoxDecoration(borderRadius:BorderRadius.circular(20),color:Color(0xFF1E293B)),child:b64!=null&&b64.length>100?ClipRRect(borderRadius:BorderRadius.circular(20),child:Image.memory(base64Decode(b64.split(',').last),fit:BoxFit.cover,width:double.infinity)):Center(child:Text("Banner 1 - Upload in Admin",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))));}),Padding(padding:EdgeInsets.all(12),child:Text("Latest Release",style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold))),SizedBox(height:140,child:ListView.builder(scrollDirection:Axis.horizontal,padding:EdgeInsets.symmetric(horizontal:12),itemCount:all.isEmpty?3:all.length,itemBuilder:(c,i){if(all.isEmpty)return Container(width:100,margin:EdgeInsets.only(right:10),decoration:BoxDecoration(color:Color(0xFF1E3A4E),borderRadius:BorderRadius.circular(15)),child:Icon(Icons.movie,color:Colors.white));final m=Map<String,dynamic>.from(all[i].value as Map);final poster=m['posterBase64']??'';return GestureDetector(onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>DetailPage(data:m,id:all[i].key))),child:Container(width:110,margin:EdgeInsets.only(right:10),decoration:BoxDecoration(color:Color(0xFF1E3A4E),borderRadius:BorderRadius.circular(15)),child:ClipRRect(borderRadius:BorderRadius.circular(15),child:poster.toString().length>100?Image.memory(base64Decode(poster.toString().split(',').last),fit:BoxFit.cover):Icon(Icons.movie,color:Colors.white))));})),Padding(padding:EdgeInsets.all(12),child:Text("Trending",style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold))),SizedBox(height:140,child:ListView.builder(scrollDirection:Axis.horizontal,padding:EdgeInsets.symmetric(horizontal:12),itemCount:all.isEmpty?3:all.length,itemBuilder:(c,i){if(all.isEmpty)return Container(width:100,margin:EdgeInsets.only(right:10),decoration:BoxDecoration(color:Color(0xFF1E3A4E),borderRadius:BorderRadius.circular(15)),child:Icon(Icons.movie,color:Colors.white));final m=Map<String,dynamic>.from(all[i].value as Map);final poster=m['posterBase64']??'';return Container(width:110,margin:EdgeInsets.only(right:10),decoration:BoxDecoration(color:Color(0xFF1E3A4E),borderRadius:BorderRadius.circular(15)),child:ClipRRect(borderRadius:BorderRadius.circular(15),child:poster.toString().length>100?Image.memory(base64Decode(poster.toString().split(',').last),fit:BoxFit.cover):Icon(Icons.movie,color:Colors.white)));}))]));}))]));
  }
}
class MoviesTab extends StatelessWidget{
  MoviesTab({super.key});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){return StreamBuilder(stream:ref.onValue,builder:(c,snap){if(!snap.hasData||snap.data!.snapshot.value==null)return Center(child:Text("No Movies",style:TextStyle(color:Colors.white54)));final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);final list=map.entries.toList();return GridView.builder(padding:EdgeInsets.all(12),gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:0.65,crossAxisSpacing:10,mainAxisSpacing:10),itemCount:list.length,itemBuilder:(c,i){final m=Map<String,dynamic>.from(list[i].value as Map);final poster=m['posterBase64']??'';return GestureDetector(onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>DetailPage(data:m,id:list[i].key))),child:Container(decoration:BoxDecoration(color:Color(0xFF1E293B),borderRadius:BorderRadius.circular(12)),child:poster.toString().length>100?ClipRRect(borderRadius:BorderRadius.circular(12),child:Image.memory(base64Decode(poster.toString().split(',').last),fit:BoxFit.cover)):Icon(Icons.movie,color:Colors.white)));});});}
}
class SeriesTab extends StatelessWidget{
  SeriesTab({super.key});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){return StreamBuilder(stream:ref.onValue,builder:(c,snap){if(!snap.hasData||snap.data!.snapshot.value==null)return Center(child:Text("No Series",style:TextStyle(color:Colors.white54)));final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);final list=map.entries.where((e)=>(Map<String,dynamic>.from(e.value as Map)['category']??'').toString().toLowerCase().contains('series')).toList();return GridView.builder(padding:EdgeInsets.all(12),gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:0.65,crossAxisSpacing:10,mainAxisSpacing:10),itemCount:list.length,itemBuilder:(c,i){final m=Map<String,dynamic>.from(list[i].value as Map);final poster=m['posterBase64']??'';return GestureDetector(onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>DetailPage(data:m,id:list[i].key))),child:Container(decoration:BoxDecoration(color:Color(0xFF1E293B),borderRadius:BorderRadius.circular(12)),child:poster.toString().length>100?ClipRRect(borderRadius:BorderRadius.circular(12),child:Image.memory(base64Decode(poster.toString().split(',').last),fit:BoxFit.cover)):Icon(Icons.tv,color:Colors.white)));});});}
}
class DetailPage extends StatelessWidget{
  final Map<String,dynamic> data;final String id;
  const DetailPage({super.key,required this.data,required this.id});
  @override Widget build(BuildContext context){
    final casts=data['casts'] is List?data['casts'] as List:[];
    return Scaffold(backgroundColor:Color(0xFF020617),appBar:AppBar(backgroundColor:Color(0xFF020617),title:Text(data['title']??'')),body:SingleChildScrollView(padding:EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(data['title']??'',style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold)),Text("${data['vj']??''} - ${data['genre']??''}",style:TextStyle(color:Colors.white54)),SizedBox(height:12),Text("Casts (5 max)",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),SizedBox(height:8),casts.isEmpty?Text("No casts",style:TextStyle(color:Colors.white54)):SizedBox(height:100,child:ListView.builder(scrollDirection:Axis.horizontal,itemCount:casts.length>5?5:casts.length,itemBuilder:(c,i){final cast=Map<String,dynamic>.from(casts[i] as Map);final img=cast['imageBase64']??'';return Container(width:70,margin:EdgeInsets.only(right:10),child:Column(children:[CircleAvatar(radius:25,backgroundImage:img.toString().length>100?MemoryImage(base64Decode(img.toString().split(',').last)):null,child:img.toString().length<100?Icon(Icons.person):null),Text(cast['realName']??'',maxLines:1,style:TextStyle(color:Colors.white,fontSize:10))]));})),SizedBox(height:12),Text(data['description']??'',style:TextStyle(color:Colors.white70))])));
  }
}
class DownloadsTab extends StatefulWidget{const DownloadsTab({super.key});@override State<DownloadsTab> createState()=>DownloadsTabState();}
class DownloadsTabState extends State<DownloadsTab> with SingleTickerProviderStateMixin{
  late TabController tab;
  @override void initState(){super.initState();tab=TabController(length:2,vsync:this);}
  @override Widget build(BuildContext context){return SafeArea(child:Column(children:[Container(margin:EdgeInsets.all(12),padding:EdgeInsets.all(12),decoration:BoxDecoration(color:Color(0xFF1E293B),borderRadius:BorderRadius.circular(12)),child:Row(children:[Icon(Icons.storage,color:Color(0xFF38BDF8)),SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text("Used: 3.2GB / 15.7GB",style:TextStyle(color:Colors.white,fontSize:12)),LinearProgressIndicator(value:0.2,color:Color(0xFF38BDF8)),Text("Free: 12.5GB available",style:TextStyle(color:Colors.white54,fontSize:10))]))])),TabBar(controller:tab,labelColor:Color(0xFF38BDF8),tabs:[Tab(text:"Downloading"),Tab(text:"Completed")]),Expanded(child:TabBarView(controller:tab,children:[Center(child:Text("No active downloads",style:TextStyle(color:Colors.white54))),Center(child:Text("No available download",style:TextStyle(color:Colors.white54)))]))]));
  }
}
class ProfileTab extends StatefulWidget{final Function(bool) onTheme;final String email;final bool isAdmin;const ProfileTab({super.key,required this.onTheme,required this.email,required this.isAdmin});@override State<ProfileTab> createState()=>ProfileTabState();}
class ProfileTabState extends State<ProfileTab>{
  final picker=ImagePicker();Uint8List? avatarBytes;
  void pickAvatar() async {final x=await picker.pickImage(source:ImageSource.gallery);if(x!=null){final b=await x.readAsBytes();setState(()=>avatarBytes=b);final p=await SharedPreferences.getInstance();await p.setString('avatar',base64Encode(b));}}
  @override void initState(){super.initState();loadAvatar();}
  void loadAvatar() async {final p=await SharedPreferences.getInstance();final av=p.getString('avatar');if(av!=null)setState(()=>avatarBytes=base64Decode(av));}
  @override Widget build(BuildContext context){return ListView(padding:EdgeInsets.all(12),children:[Center(child:GestureDetector(onTap:pickAvatar,child:CircleAvatar(radius:45,backgroundImage:avatarBytes!=null?MemoryImage(avatarBytes!):null,child:avatarBytes==null?Icon(Icons.person,size:40):null))),Center(child:Text(widget.email,style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))),Center(child:Text(widget.isAdmin?"ADMIN":"USER",style:TextStyle(color:widget.isAdmin?Colors.orange:Color(0xFF38BDF8)))),SizedBox(height:20),if(widget.isAdmin)Container(decoration:BoxDecoration(color:Colors.orange,borderRadius:BorderRadius.circular(12)),child:ListTile(title:Text("Go to ADMIN PANEL",style:TextStyle(color:Colors.black,fontWeight:FontWeight.bold)),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AdminMainNav(email:widget.email))))),ListTile(leading:Icon(Icons.download,color:Color(0xFF38BDF8)),title:Text("Download Latest APK"),onTap:() async {final uri=Uri.parse("https://github.com/bluezzer/onyx-movie-final/releases");if(await canLaunchUrl(uri))await launchUrl(uri,mode:LaunchMode.externalApplication);}),ListTile(leading:Icon(Icons.security,color:Color(0xFF38BDF8)),title:Text("Security Biometric"),onTap:() async {final auth=LocalAuthentication();if(await auth.canCheckBiometrics){final did=await auth.authenticate(localizedReason:"Auth");if(did&&mounted){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Authenticated")));}}}),ListTile(leading:Icon(Icons.logout,color:Colors.red),title:Text("Logout",style:TextStyle(color:Colors.red)),onTap:() async {final p=await SharedPreferences.getInstance();await p.clear();if(context.mounted)Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>AuthScreen(onTheme:widget.onTheme)),(r)=>false);})]);
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
  final String email;
  const AdminDashboardTab({super.key,required this.email});
  @override Widget build(BuildContext context){return ListView(padding:EdgeInsets.all(16),children:[Container(padding:EdgeInsets.all(20),decoration:BoxDecoration(color:Color(0xFF1E293B),borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text("Admin Dashboard",style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold)),Text(email,style:TextStyle(color:Colors.orange)),Text("Storage: 3.2GB / 15.7GB Used - Free 12.5GB",style:TextStyle(color:Colors.white54,fontSize:12))])),SizedBox(height:16),ElevatedButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AdminAddMovie())),style:ElevatedButton.styleFrom(backgroundColor:Colors.orange),child:Text("Add Banner 1 + Movie + 5 Casts",style:TextStyle(color:Colors.black)))]);
  }
}
class AdminManageMovies extends StatelessWidget{
  AdminManageMovies({super.key});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext context){return StreamBuilder(stream:ref.onValue,builder:(c,snap){if(!snap.hasData||snap.data!.snapshot.value==null)return Center(child:Text("No movies",style:TextStyle(color:Colors.white54)));final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);final list=map.entries.toList();return ListView.builder(padding:EdgeInsets.all(12),itemCount:list.length,itemBuilder:(c,i){final m=Map<String,dynamic>.from(list[i].value as Map);return Card(color:Color(0xFF1E293B),child:ListTile(title:Text(m['title']??'',style:TextStyle(color:Colors.white)),subtitle:Text("${m['category']??''}",style:TextStyle(color:Colors.white54,fontSize:11)),trailing:IconButton(icon:Icon(Icons.delete,color:Colors.red),onPressed:() async => await ref.child(list[i].
