import 'package:flutter/material.dart';
import '/models/job_opportunities_model.dart';
import '/repositories/job_repository.dart';
import 'auth_provider.dart';

class JobProvider extends ChangeNotifier {
  final JobRepository _repository;
  AuthProvider? _authProvider;

  JobProvider(this._repository);

  Stream<List<JobOpportunities>> get jobs => _repository.watchJobs();

  Future<void> addJob(JobOpportunities job) async {
    final userId = _authProvider?.user?.uid;
    if (userId == null) return;
    await _repository.addJob(job, userId);
  }

  Future<void> updateJob(JobOpportunities job) async {
    final userId = _authProvider?.user?.uid;
    if (userId == null) return;
    await _repository.updateJob(job, userId);
  }
}