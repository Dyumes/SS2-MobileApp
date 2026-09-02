import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/models/employer_model.dart';
import 'package:jobinder/models/student_model.dart';
import 'package:jobinder/repositories/firestore_user_repository.dart';
import 'package:jobinder/repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/face_service.dart';

/// Provider class for managing authentication state and actions, which notifies listeners on changes.
class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  User? _user;
  AppUser? _appUser;
  bool _isLoading = false;
  String? _errorMessage;

  Stream<List<AppUser>> get users => FirestoreUserRepository().watchUsers();

  User? get user => _user;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider(this._authService) {
    _authService.authStateChanges().listen((User? user) async {
      UserRepository userRepository = FirestoreUserRepository();
      _user = user;
      _appUser = null;

      // Fetch AppUser details
      if (user != null) {
        _appUser = await userRepository.getUser(user.uid);
      }

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
    Student student,
  ) {
    Future<String?> registerUser() async {
      UserRepository userRepository = FirestoreUserRepository();
      String? error = await _authService.registerWithEmailAndPassword(
        email,
        password,
      );
      if (error == null) {
        await userRepository.addStudentUser(user, student, _authService.currentUser!.uid);
      }
      return error;
    }

    return _authenticate(() => registerUser());
  }

  Future<bool> registerEmployerWithEmailAndPassword(String email, String password, AppUser user, Employer employer) {
    Future<String?> registerUser() async {
      UserRepository userRepository = FirestoreUserRepository();
      String? error = await _authService.registerWithEmailAndPassword(
        email,
        password,
      );
      if (error == null) {
        await userRepository.addEmployerUser(user, employer, _authService.currentUser!.uid);
      }
      return error;
    }

    return _authenticate(() => registerUser());
  }

  Future<bool> editStudentProfile(AppUser user, Student student) {
    Future<String?> editUser() async {
      UserRepository userRepository = FirestoreUserRepository();
      await userRepository.addStudentUser(user, student, _authService.currentUser!.uid);
      return null; // No error
    }

    return _authenticate(() => editUser());
  }

  Future<String?> findUserEmailByFaceVector(
    List<double> currentVector,
    FaceRecognitionService faceService,
  ) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('user').get();

      final Map<String, List<double>> registeredUsers = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final email = data['email'] as String?;
        final rawEmbedding = data['faceEmbedding'] ?? data['faceVector'];

        if (email != null &&
            email.isNotEmpty &&
            rawEmbedding != null &&
            rawEmbedding is List &&
            rawEmbedding.isNotEmpty) {
          final vector =
              rawEmbedding.map((e) => (e as num).toDouble()).toList();

          if (vector.length == 192) {
            registeredUsers[email] = vector;
          }
        }
      }

      if (registeredUsers.isEmpty) {
        return null;
      }

      final match = faceService.findFromList(currentVector, registeredUsers);

      if (match.isRecognized) {
        return match.name;
      }
    } catch (e) {
    }
    return null;
  }

  Future<List<double>?> getFaceEmbeddingForUser(String email) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final data = querySnapshot.docs.first.data();
      final rawEmbedding = data['faceEmbedding'] ?? data['faceVector'];

      if (rawEmbedding != null && rawEmbedding is List) {
        return rawEmbedding.map((e) => (e as num).toDouble()).toList();
      }
    } catch (e) {
    }
    return null;
  }

  Future<Map<String, List<double>>> getAllUsersFaceEmbeddings() async {
    final Map<String, List<double>> registeredUsers = {};
    
    try {

      final querySnapshot =
          await FirebaseFirestore.instance.collection('user').get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final rawEmbedding = data['faceEmbedding'] ?? data['faceVector'];

        if (rawEmbedding != null && rawEmbedding is List) {
          final List<double> vector =
              rawEmbedding.map((e) => (e as num).toDouble()).toList();

          if (vector.length == 192) {
            registeredUsers[doc.id] = vector;
          }
        }
      }
    } catch (e) {
    }

    return registeredUsers;
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