import '../models/employer_model.dart';
import '../models/AppUser_model.dart';

abstract class EmployerRepository {
  Future<Employer?> getEmployerByUid(String uid);
  Future<AppUser?> getUser(String uid);
}