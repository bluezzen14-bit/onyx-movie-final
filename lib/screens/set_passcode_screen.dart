import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SetPasscodeScreen extends StatefulWidget {
  final VoidCallback onSet;
  const SetPasscodeScreen({super.key, required this.onSet});
  @override
  State<SetPasscodeScreen> createState() => _SetPasscodeScreenState();
}

class _SetPasscodeScreenState extends State<SetPasscodeScreen> {
  final _controller = TextEditingController();
  final _service = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Set 4-digit Passcode", style: TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 20),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_controller.text.length == 4) {
                  await _service.savePasscode(_controller.text);
                  widget.onSet();
                }
              },
              child: const Text("SAVE PASSCODE"),
            )
          ],
        ),
      ),
    );
  }
}
