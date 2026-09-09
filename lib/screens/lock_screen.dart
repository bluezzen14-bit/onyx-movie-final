import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/auth_service.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _authService = AuthService();
  final _pinController = TextEditingController();
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    try {
      bool canCheck = await _localAuth.canCheckBiometrics;
      bool isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) return;

      bool didAuth = await _localAuth.authenticate(
        localizedReason: 'Unlock Onyx Movies',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (didAuth) widget.onUnlocked();
    } catch (_) {}
  }

  Future<void> _checkPin() async {
    String? saved = await _authService.getPasscode();
    if (_pinController.text == saved) {
      widget.onUnlocked();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wrong passcode")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text("Enter Passcode", style: TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(color: Colors.white, letterSpacing: 20, fontSize: 24),
              decoration: const InputDecoration(counterText: "", border: OutlineInputBorder()),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _checkPin, child: const Text("UNLOCK")),
            const SizedBox(height: 20),
            IconButton(icon: const Icon(Icons.fingerprint, size: 50, color: Colors.white), onPressed: _tryBiometric),
            const Text("Tap for Fingerprint", style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
