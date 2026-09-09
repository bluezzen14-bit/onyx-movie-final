import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();

  User? get currentUser => _auth.currentUser;

  // GOOGLE SIGN IN / REGISTER (same function)
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception("Cancelled");
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  // PASSCODE
  Future<void> savePasscode(String code) async {
    await _storage.write(key: 'app_passcode', value: code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_passcode', true);
  }

  Future<String?> getPasscode() async {
    return await _storage.read(key: 'app_passcode');
  }

  Future<bool> hasPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_passcode') ?? false;
  }
}
