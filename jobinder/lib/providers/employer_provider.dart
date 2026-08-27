import 'package:flutter/material.dart';
import '/models/employer_model.dart';
import '/models/AppUser_model.dart';
import '/repositories/employer_repository.dart';
import 'auth_provider.dart';

class EmployerProvider extends ChangeNotifier {
  final EmployerRepository _repository;
  AuthProvider? _authProvider;
  Employer? _employer;
  AppUser? _user;


  Employer? get employer => _employer;
  String? get employerId => _employer?.user_id;
  AppUser? get user => _user;


  EmployerProvider(this._repository);

  void updateAuth(AuthProvider auth) {
    _authProvider = auth;
    _employer = null;
    load();
  }

Future<void> load() async {
  final uid = _authProvider?.user?.uid;
  if (uid == null) return;
  _employer = await _repository.getEmployerByUid(uid);
  _user = await _repository.getUser(uid);
  notifyListeners();
}
}