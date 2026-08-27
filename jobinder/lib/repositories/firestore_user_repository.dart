import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/repositories/user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('user');

  @override
  Stream<List<AppUser>> watchUsers() {
    return _usersRef.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          return AppUser.fromMap(doc.data(), doc.id);
        }).toList());
  }
  
  @override
  Future<void> addUser(AppUser usr, String userId) async {
    await _usersRef.doc(userId).set(usr.toMap());
  }
}