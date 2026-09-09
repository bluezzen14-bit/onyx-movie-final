import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text("Register / Sign In with Google"),
          onPressed: () async {
            try { await _auth.signInWithGoogle(); } catch(e){ print(e); }
          },
        ),
      ),
    );
  }
}
