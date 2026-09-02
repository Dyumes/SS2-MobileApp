import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/models/employer_model.dart';
import 'package:jobinder/models/student_model.dart';
import 'package:jobinder/repositories/user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('user');
  CollectionReference<Map<String, dynamic>> get _studentsRef =>
      _db.collection('student');
  CollectionReference<Map<String, dynamic>> get _employersRef =>
      _db.collection('employer');

  @override
  Stream<List<AppUser>> watchUsers() {
    return _usersRef.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) {
        return AppUser.fromMap(doc.data(), doc.id);
      }).toList(),
    );
  }

  @override
  Future<void> addStudentUser(
    AppUser usr,
    Student student,
    String userId,
  ) async {
    await _usersRef.doc(userId).set(usr.toMap());
    await _studentsRef.doc(userId).set(student.toMap());
  }

  @override
  Future<void> addEmployerUser(
    AppUser usr,
    Employer employer,
    String userId,
  ) async {
    await _usersRef.doc(userId).set(usr.toMap());
    await _employersRef.doc(userId).set(employer.toMap());
  }

  @override
  Future<Employer> getEmployerByUid(String uid) async {
    final query = await _db
        .collection('employer')
        .doc(uid)
        .get();

    // if (query.docs.isEmpty) return null;
    return Employer.fromMap(query.data()!, query.id);
  }

  @override
  Future<Student> getStudentByUid(String uid) async {
    final query = await _db
        .collection('student')
        .doc(uid)
        .get();

    // if (query.docs.isEmpty) return null;
    return Student.fromMap(query.data()!, query.id);
  }

  @override
  Future<AppUser> getUser(String uid) async {
    final snap = await _db.collection('user').doc(uid).get();
    // if (!snap.exists) return null;
    return AppUser.fromMap(snap.data()!, uid);
  }

  @override
  Future<void> updateStudentProfile(
    String uid, {
    required String address,
    required List<String> skills,
    required List<History> history,
    String? degree,
    int? minSalary,
    int? maxDistance
  }) async {
    await FirebaseFirestore.instance
        .collection('student')         
        .doc(uid)                      
        .update({
      'skills': skills,
      'history': history.map((h) => h.toMap()).toList(),
      'degree': degree,
      'minSalary': minSalary,
      'maxDistance': maxDistance
    });
    await FirebaseFirestore.instance
      .collection('user')
      .doc(uid)
      .update({
        'address': address
      });
  }

  @override
  Future<void> updateEmployerProfile(
    String uid, {
    required String address,
    required String canton,
    required String city,
    required String companySize,
  }) async {
    await FirebaseFirestore.instance
        .collection('employer')
        .doc(uid)
        .update({
      'canton': canton,
      'city': city,
      'company_size': companySize,
    });
    await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .update({
      'address': address,
    });
  }
}
