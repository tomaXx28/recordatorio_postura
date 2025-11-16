import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  // usuario actual
  User? get currentUser => _auth.currentUser;

  // escuchar cambios de sesión
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // login
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // registro
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
  