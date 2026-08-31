import 'package:jobinder/models/employer_model.dart';
import 'package:jobinder/models/student_model.dart';

import '../models/appuser_model.dart';

abstract class UserRepository {
  Stream<List<AppUser>> watchUsers();
  Future<void> addStudentUser(AppUser user, Student student, String userId);
  Future<void> addEmployerUser(AppUser user, Employer employer, String userId);

  Future<Employer?> getEmployerByUid(String uid);
  Future<Student?> getStudentByUid(String uid);
  Future<AppUser?> getUser(String uid);
}
