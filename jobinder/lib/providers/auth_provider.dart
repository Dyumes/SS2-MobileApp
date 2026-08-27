import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/repositories/firestore_user_repository.dart';
import 'package:jobinder/repositories/user_repository.dart';
import '../services/auth_service.dart';

/// Provider class for managing authentication state and actions, which notifies listeners on changes.
class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider(this._authService) {
    _authService.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) {
    return _authenticate(
      () => _authService.signInWithEmailAndPassword(email, password),
    );
  }

  /// Registers a student with email and password, and adds the user to the Firestore database.
  Future<bool> registerStudentWithEmailAndPassword(
    String email,
    String password,
    AppUser user,
  ) {
    Future<String?> registerUser() async {
      UserRepository userRepository = FirestoreUserRepository();
      String? error = await _authService.registerWithEmailAndPassword(
        email,
        password,
      );
      if (error == null) {
        await userRepository.addUser(user, _authService.currentUser!.uid);
      }
      return error;
    }

    return _authenticate(() => registerUser());
  }

  Future<bool> registerEmployeeWithEmailAndPassword(String email, String password) {
    return _authenticate(
      () => _authService.registerWithEmailAndPassword(email, password),
    );
  }

  Future<bool> _authenticate(Future<String?> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify the listeners

    final error = await action();

    _isLoading = false;
    _errorMessage = error;
    notifyListeners();

    return error == null;
  }

  Future<void> signOut() async {
    _errorMessage = await _authService.signOut();
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
