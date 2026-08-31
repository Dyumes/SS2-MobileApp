import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobinder/services/auth_service.dart';

class FakeAuthService implements AuthService {
  final _authStateController = StreamController<User?>.broadcast();
  User? _currentUser;
  
  String? signInError;
  String? registerError;
  String? signOutError;
  Completer<void>? gate;

  void emitUser(User? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> authStateChanges() => _authStateController.stream;

  @override
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    if (gate != null) await gate!.future;
    return signInError;
  }

  @override
  Future<String?> registerWithEmailAndPassword(String email, String password) async {
    if (gate != null) await gate!.future;
    return registerError;
  }

  @override
  Future<String?> signOut() async {
    return signOutError;
  }

  void dispose() {
    _authStateController.close();
  }
}