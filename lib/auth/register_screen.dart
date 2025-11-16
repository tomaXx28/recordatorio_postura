import 'package:flutter/material.dart';
import '../auth/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            if (errorMessage != null)
              Text(errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14)),

            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      setState(() => loading = true);

                      final error = await AuthService().register(
                        emailCtrl.text,
                        passCtrl.text,
                      );

                      if (error != null) {
                        setState(() {
                          errorMessage = error;
                          loading = false;
                        });
                        return;
                      }

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Crear cuenta"),
            ),
          ],
        ),
      ),
    );
  }
}
