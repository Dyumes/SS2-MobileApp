import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobinder/models/job_opportunities_model.dart';
import '../models/job_opportunities_model.dart';
import 'job_repository.dart';

class FirestoreJobRepository implements JobRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _jobsRef =>
      _db.collection('job_opportunities');

  @override
  Stream<List<JobOpportunities>> watchJobs() {
    return _jobsRef.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          return JobOpportunities.fromMap(doc.data(), doc.id);
        }).toList());
  }

  @override
  Future<void> addJob(JobOpportunities job, String userId) async {
    await _jobsRef.add(job.toMap());
  }

  @override
  Future<void> updateJob(JobOpportunities job, String userId) async {
    await _jobsRef.doc(job.employer_user).update(job.toMap());
  }

  @override
  Future<void> deleteJob(String jobId, String userId) async {
    await _jobsRef.doc(jobId).delete();
  }
}