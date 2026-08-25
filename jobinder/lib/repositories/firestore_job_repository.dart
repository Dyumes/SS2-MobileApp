import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import 'job_repository.dart';

class FirestoreJobRepository implements JobRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _jobsRef =>
      _db.collection('job');

  @override
  Stream<List<Job>> watchJobs() {
    return _jobsRef.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          return Job.fromMap(doc.data(), doc.id);
        }).toList());
  }
}