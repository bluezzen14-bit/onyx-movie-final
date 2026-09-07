import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(); } catch (e) {}
  runApp(const OnyxApp());
}

class OnyxApp extends StatelessWidget {
  const OnyxApp({super.key});
  @override Widget build(BuildContext c) => MaterialApp(debugShowCheckedModeBanner:false, theme:ThemeData.dark().copyWith(scaffoldBackgroundColor:Colors.black), home:const Splash());
}

class Splash extends StatefulWidget { const Splash({super.key}); @override State<Splash> createState()=>SplashState(); }
class SplashState extends State<Splash>{
  @override void initState(){ super.initState(); check(); }
  check() async {
    await Future.delayed(const Duration(seconds:2));
    final p=await SharedPreferences.getInstance();
    final email=p.getString('registered_email_permanent');
    final logged=p.getBool('is_logged_in')??false;
    if(email!=null&&logged){ if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>MainNav(email:email,isAdmin:p.getBool('is_admin')??false))); }
    else{ if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>const Login())); }
  }
  @override Widget build(BuildContext c)=>const Scaffold(body:Center(child:CircularProgressIndicator(color:Colors.orange)));
}

class Login extends StatefulWidget{ const Login({super.key}); @override State<Login> createState()=>LoginState(); }
class LoginState extends State<Login>{
  final eC=TextEditingController(); final pC=TextEditingController(); bool load=false; String err='';
  login() async{
    if(eC.text.isEmpty||pC.text.isEmpty){ setState(()=>err='Enter email + password'); return; }
    setState(()=>load=true);
    final p=await SharedPreferences.getInstance();
    final email=eC.text.trim().toLowerCase();
    bool isAdmin=email=='mugabibenjamin14@gmail.com'&&pC.text=='Mugabibe+-@1';
    await p.setString('registered_email_permanent',email);
    await p.setBool('is_logged_in',true); await p.setBool('is_admin',isAdmin);
    if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>MainNav(email:email,isAdmin:isAdmin)));
    setState(()=>load=false);
  }
  @override Widget build(BuildContext c)=>Scaffold(body:Padding(padding:EdgeInsets.all(20), child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[Text('ONYX MOVIES',style:TextStyle(fontSize:24,color:Colors.orange,fontWeight:FontWeight.bold)), SizedBox(height:20), TextField(controller:eC,decoration:InputDecoration(labelText:'Email')), TextField(controller:pC,decoration:InputDecoration(labelText:'Password'),obscureText:true), SizedBox(height:10), if(err.isNotEmpty) Text(err,style:TextStyle(color:Colors.red)), ElevatedButton(onPressed:login, child:Text(load?'...':'LOGIN FOREVER'))])));
}

class MainNav extends StatefulWidget{ final String email; final bool isAdmin; const MainNav({super.key,required this.email,required this.isAdmin}); @override State<MainNav> createState()=>MainNavState(); }
class MainNavState extends State<MainNav>{ int idx=0; @override Widget build(BuildContext c){ final pages=[HomeSimple(email:widget.email,isAdmin:widget.isAdmin), ProfileTab(email:widget.email,isAdmin:widget.isAdmin)]; return Scaffold(backgroundColor:Colors.black, body:pages[idx], bottomNavigationBar:BottomNavigationBar(currentIndex:idx, onTap:(i)=>setState(()=>idx=i), items:[BottomNavigationBarItem(icon:Icon(Icons.home),label:'Home'), BottomNavigationBarItem(icon:Icon(Icons.person),label:'Profile')])); } }

class HomeSimple extends StatelessWidget{
  final String email; final bool isAdmin; HomeSimple({super.key,required this.email,required this.isAdmin});
  final ref=FirebaseDatabase.instance.ref('movies');
  @override Widget build(BuildContext c){
    return SafeArea(child:Column(children:[
      Padding(padding:EdgeInsets.all(12), child:Row(children:[Expanded(child:Text('Auto-login: $email',style:TextStyle(color:Colors.green,fontSize:11))), if(isAdmin) ElevatedButton(onPressed:(){Navigator.push(c,MaterialPageRoute(builder:(_)=>AdminMain(email:email)));}, child:Text('ADMIN'))])),
      Expanded(child:StreamBuilder(stream:ref.orderByChild('timestamp').onValue, builder:(c,snap){
        if(!snap.hasData) return Center(child:CircularProgressIndicator(color:Colors.orange));
        if(snap.data!.snapshot.value==null) return Center(child:Text('No movies yet',style:TextStyle(color:Colors.white54)));
        final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map);
        final list=map.entries.toList();
        return GridView.builder(padding:EdgeInsets.all(8), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:0.68), itemCount:list.length, itemBuilder:(c,i){
          final m=Map<String,dynamic>.from(list[i].value as Map); final poster=m['posterBase64']??'';
          return Card(color:Color(0xFF1E293B), child:Column(children:[Expanded(child:poster.isNotEmpty?Image.memory(base64Decode(poster),fit:BoxFit.cover,width:double.infinity):Icon(Icons.movie)), Padding(padding:EdgeInsets.all(4), child:Text(m['title']??'',style:TextStyle(color:Colors.white,fontSize:11))) ]));
        });
      }))
    ]));
  }
}

class ProfileTab extends StatelessWidget{
  final String email; final bool isAdmin; const ProfileTab({super.key,required this.email,required this.isAdmin});
  @override Widget build(BuildContext c)=>SafeArea(child:ListView(padding:EdgeInsets.all(16), children:[Text(email), if(isAdmin) ElevatedButton(onPressed:(){Navigator.push(c,MaterialPageRoute(builder:(_)=>AdminMain(email:email)));}, child:Text('ADMIN')), ElevatedButton(onPressed:() async {final p=await SharedPreferences.getInstance(); await p.clear(); if(c.mounted) Navigator.pushReplacement(c,MaterialPageRoute(builder:(_)=>Login()));}, child:Text('Logout'))]));
}

class AdminMain extends StatefulWidget{ final String email; const AdminMain({super.key,required this.email}); @override State<AdminMain> createState()=>AdminMainState(); }
class AdminMainState extends State<AdminMain>{ int idx=0; @override Widget build(BuildContext c){ final pages=[AdminDash(email:widget.email), AdminAdd(), AdminManage()]; return Scaffold(appBar:AppBar(title:Text('ADMIN')), body:pages[idx], bottomNavigationBar:BottomNavigationBar(currentIndex:idx, onTap:(i)=>setState(()=>idx=i), items:[BottomNavigationBarItem(icon:Icon(Icons.dashboard),label:'Dash'), BottomNavigationBarItem(icon:Icon(Icons.upload),label:'Upload'), BottomNavigationBarItem(icon:Icon(Icons.list),label:'Manage')])); } }
class AdminDash extends StatelessWidget{ final String email; AdminDash({super.key,required this.email}); final ref=FirebaseDatabase.instance.ref('movies'); @override Widget build(BuildContext c)=>StreamBuilder(stream:ref.onValue, builder:(c,s){int total=0; if(s.hasData&&s.data!.snapshot.value!=null) total=Map<String,dynamic>.from(s.data!.snapshot.value as Map).length; return Center(child:Text('Total Movies: $total'));}); }
class AdminManage extends StatelessWidget{ const AdminManage({super.key}); @override Widget build(BuildContext c){ final ref=FirebaseDatabase.instance.ref('movies'); return StreamBuilder(stream:ref.onValue, builder:(c,snap){ if(!snap.hasData) return Center(child:CircularProgressIndicator()); if(snap.data!.snapshot.value==null) return Center(child:Text('No movies')); final map=Map<String,dynamic>.from(snap.data!.snapshot.value as Map); final list=map.entries.toList(); return ListView.builder(itemCount:list.length, itemBuilder:(c,i){ final m=Map<String,dynamic>.from(list[i].value as Map); return ListTile(title:Text(m['title']??''), trailing:IconButton(icon:Icon(Icons.delete,color:Colors.red), onPressed:() async {await ref.child(list[i].key).remove();})); }); }); } }
class AdminAdd extends StatefulWidget{ const AdminAdd({super.key}); @override State<AdminAdd> createState()=>AdminAddState(); }
class AdminAddState extends State<AdminAdd>{
  final titleC=TextEditingController(); final descC=TextEditingController(); Uint8List? posterBytes; final picker=ImagePicker(); bool uploading=false;
  pickPoster() async {final x=await picker.pickImage(source:ImageSource.gallery,imageQuality:40); if(x!=null){final b=await x.readAsBytes(); setState(()=>posterBytes=b);} }
  upload() async{ if(titleC.text.isEmpty||posterBytes==null){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Title + Poster needed'))); return; } setState(()=>uploading=true); final ref=FirebaseDatabase.instance.ref('movies').push(); await ref.set({'title':titleC.text,'description':descC.text,'posterBase64':base64Encode(posterBytes!),'timestamp':ServerValue.timestamp}); setState(()=>uploading=false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Uploaded'),backgroundColor:Colors.green)); }
  @override Widget build(BuildContext c)=>ListView(padding:EdgeInsets.all(12), children:[TextField(controller:titleC,decoration:InputDecoration(labelText:'Title *')), TextField(controller:descC,decoration:InputDecoration(labelText:'Description')), SizedBox(height:8), ElevatedButton(onPressed:pickPoster, child:Text(posterBytes==null?'Pick Poster':'Poster OK')), SizedBox(height:20), ElevatedButton(onPressed:uploading?null:upload, child:Text(uploading?'Uploading...':'UPLOAD'))]);
}
