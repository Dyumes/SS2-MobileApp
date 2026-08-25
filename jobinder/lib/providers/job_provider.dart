import 'package:flutter/material.dart';
import '/models/job_model.dart';
import '/repositories/job_repository.dart';

class JobProvider extends ChangeNotifier {
  final JobRepository _repository;

  JobProvider(this._repository);

  Stream<List<Job>> get jobs => _repository.watchJobs();
}