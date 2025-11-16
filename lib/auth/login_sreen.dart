import 'package:flutter/material.dart';
import 'package:recordatorios_postura/auth/register_screen.dart';
import 'package:recordatorios_postura/screens/home_scren.dart';
import '../auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar sesión")),
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

                      final error = await AuthService().login(
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                        );
                      }
                    },
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Entrar"),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text("Crear cuenta"),
            )
          ],
        ),
      ),
    );
  }
}
