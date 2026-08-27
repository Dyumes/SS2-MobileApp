import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employer_model.dart';
import '../models/AppUser_model.dart';
import 'employer_repository.dart';

class FirestoreEmployerRepository implements EmployerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<Employer?> getEmployerByUid(String uid) async {
    final query = await _db
        .collection('employer')
        .where('user_id', isEqualTo: _db.doc('user/$uid'))
        .limit(1)
        .get();

if (query.docs.isEmpty) return null;
return Employer.fromMap(query.docs.first.data(), query.docs.first.id);
  }

  Future<AppUser?> getUser(String uid) async {
    final snap = await _db.collection('user').doc(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromMap(snap.data()!);
  }
}