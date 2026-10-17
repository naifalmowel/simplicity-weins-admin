import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import 'firestore_service.dart';

class AuthService {
  FirebaseAuth? _auth;
  final FirestoreService _firestoreService;

  AuthService(this._firestoreService) {
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
    }
    return Stream.value(null);
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
    final storedPin = await _firestoreService.getAdminPin();
    if (pin.trim() == storedPin || pin.trim() == AppConstants.adminPin) {
      return true;
    }
    throw Exception("رمز PIN غير صحيح");
  }

  Future<void> changeAdminPassword(String newPassword) async {
    if (_auth != null && _auth!.currentUser != null) {
      await _auth!.currentUser!.updatePassword(newPassword.trim());
    }
  }

  Future<void> changeAdminPin(String newPin) async {
    await _firestoreService.updateAdminPin(newPin.trim());
  }

  Future<void> signOut() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
  }
}
