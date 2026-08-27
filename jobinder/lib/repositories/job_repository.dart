import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobinder/models/job_opportunities_model.dart';

import '../models/job_opportunities_model.dart';

abstract class JobRepository {
  Stream<List<JobOpportunities>> watchJobs();
  Future<void> addJob(JobOpportunities job, String userId);
  Future<void> updateJob(JobOpportunities job, String userId);
  Future<void> deleteJob(String jobId, String userId);
  Future<String> getCompanyName(String? ref);
  Future<String?> getEmployerUserId(String uid);
}