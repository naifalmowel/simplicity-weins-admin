import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  FirebaseAuth? _auth;

  AuthService() {
    try {
      _auth = FirebaseAuth.instance;
    } catch (e) {
      debugPrint("Firebase Auth not initialized: $e");
    }
  }

  User? get currentUser => _auth?.currentUser;

  Stream<User?> get authStateChanges {
    if (_auth != null) {
      return _auth!.authStateChanges();
    } {
      return Stream.value(null);
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    if (_auth != null) {
      try {
        await _auth!.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        return true;
      } catch (e) {
        debugPrint("Error signing in with Firebase Auth: $e");
        rethrow;
      }
    }
    // Fallback mode if Firebase not initialized
    if (email == "admin@simplicity.com" && password == "admin123") {
      return true;
    }
    throw Exception("بيانات الدخول غير صحيحة");
  }

  Future<bool> verifyAdminPin(String pin) async {
    if (pin.trim() == AppConstants.adminPin) {
      return true;
    }
    throw Exception("رمز PIN غير صحيح");
  }

  Future<void> signOut() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
  }
}
