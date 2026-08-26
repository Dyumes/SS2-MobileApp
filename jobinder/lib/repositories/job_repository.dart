import '../models/job_model.dart';

abstract class JobRepository {
  Stream<List<Job>> watchJobs();
  Future<void> addJob(Job job, String userId);
  Future<void> updateJob(Job job, String userId);
}