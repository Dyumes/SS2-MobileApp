import 'package:jobinder/models/job_opportunities_model.dart';

abstract class JobRepository {
  Stream<List<JobOpportunities>> watchJobs();
  Stream<List<JobOpportunities>> watchJobsByEmployer(String employerId);
  Future<void> addJob(JobOpportunities job, String userId);
  Future<void> updateJob(JobOpportunities job, String userId);
  Future<void> deleteJob(String jobId, String userId);
  Future<String> getCompanyName(String? ref);
  Future<String?> getEmployerUserId(String uid);
  Future<void> updateStatus(String jobId, String userId, String status);
}