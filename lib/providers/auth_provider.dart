import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();
  User? _user;

  User? get user => _user;
  Stream<User?> get authStateChanges => _service.authStateChanges;

  void init() {
    _user = _service.currentUser;
  }

  Future<void> signUp(String email, String pass) async {
    await _service.signUpWithEmail(email, pass);
    _user = _service.currentUser;
    notifyListeners();
  }

  Future<void> signIn(String email, String pass) async {
    await _service.signInWithEmail(email, pass);
    _user = _service.currentUser;
    notifyListeners();
  }

  Future<void> signInGoogle() async {
    await _service.signInWithGoogle();
    _user = _service.currentUser;
    notifyListeners();
  }

  Future<void> resetPassword(String email) => _service.sendPasswordReset(email);

  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    notifyListeners();
  }
}
