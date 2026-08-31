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
  Stream<List<JobOpportunities>> watchJobsByEmployer(String employerId) {
    print("Employer ID : $employerId");
    return _jobsRef
        .where('employer_user', isEqualTo: _db.collection("employer").doc(employerId))
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return JobOpportunities.fromMap(doc.data(), doc.id);
            }).toList());
  }

  @override
  Future<void> addJob(JobOpportunities job, String userId) async {
    await _jobsRef.add({...job.toMap(), 'employer_user': _db.doc('employer/$userId')});
  }

  @override
  Future<void> updateJob(JobOpportunities job, String userId) async {
    await _jobsRef.doc(job.employer_user).update(job.toMap());
  }

  @override
  Future<void> deleteJob(String jobId, String userId) async {
    await _jobsRef.doc(jobId).delete();
  }

  Future<String?> getEmployerUserId(String uid) async {
    final query = await _db.collection('employer')
        .where('user_id', isEqualTo: _db.doc('user/$uid'))
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }

  @override
  Future<String> getCompanyName(String? employerId) async {
    final snap = await _db.collection('employer').doc(employerId).get();
    return snap.data()?['entreprise_name'] ?? '—';
  }

  @override
  Future<void> updateStatus(String jobId, String userId, String newStatus) async {
    await _jobsRef.doc(jobId).update({'student_application.$userId': newStatus});
  }
}