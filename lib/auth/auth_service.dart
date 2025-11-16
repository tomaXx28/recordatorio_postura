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
  return translateFirebaseError(e.code);
}
  }

  // registro
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      return null;
    } on FirebaseAuthException catch (e) {
  return translateFirebaseError(e.code);
}
  }

  // logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  String translateFirebaseError(String code) {
  switch (code) {
    case 'invalid-email':
      return "El correo electrónico no es válido.";
    case 'wrong-password':
      return "La contraseña es incorrecta.";
    case 'user-not-found':
      return "No existe una cuenta con este correo.";
    case 'user-disabled':
      return "Tu cuenta ha sido deshabilitada.";
    case 'email-already-in-use':
      return "Este correo ya está registrado.";
    case 'weak-password':
      return "La contraseña debe tener al menos 6 caracteres.";
    case 'too-many-requests':
      return "Demasiados intentos. Intenta de nuevo más tarde.";
    default:
      return "Ocurrió un error inesperado. Intenta de nuevo.";
  }
}

}
