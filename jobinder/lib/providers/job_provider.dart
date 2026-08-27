import 'package:flutter/material.dart';
import '/models/job_opportunities_model.dart';
import '/repositories/job_repository.dart';
import 'auth_provider.dart';

class JobProvider extends ChangeNotifier {
  final JobRepository _repository;
  AuthProvider? _authProvider;
  String? _employerUserId;

  JobProvider(this._repository);

  Stream<List<JobOpportunities>> get jobs => _repository.watchJobs();

  void updateAuth(AuthProvider auth) {
    _authProvider = auth;
    _employerUserId = null;
  }

  Future<String?> _resolveEmployerId() async {
    if (_employerUserId != null) return _employerUserId;
    final uid = _authProvider?.user?.uid;
    if (uid == null) return null;
    _employerUserId = await _repository.getEmployerUserId(uid);
    return _employerUserId;
  }


  Future<void> addJob(JobOpportunities job) async {
    final userId = _authProvider?.user?.uid;
    //print('userId = $userId');
    if (userId == null) return;
    await _repository.addJob(job, userId);
  }

  Future<void> updateJob(JobOpportunities job) async {
    final userId = _authProvider?.user?.uid;
    if (userId == null) return;
    await _repository.updateJob(job, userId);
  }

  Future<void> deleteJob(String jobId) async {
    final employerId = await _resolveEmployerId();
    if (employerId == null) return;
    await _repository.deleteJob(jobId, employerId);
  }

  Future<String> companyName(String employerId) => _repository.getCompanyName(employerId);

  Future<String?> currentCompanyName() async {
    final employerId = await _resolveEmployerId();
    if (employerId == null) return null;
    return _repository.getCompanyName(employerId);
  }
}