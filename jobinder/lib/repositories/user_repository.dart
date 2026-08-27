import '../models/appuser_model.dart';

abstract class UserRepository {
  Stream<List<AppUser>> watchUsers();
  Future<void> addUser(AppUser user, String userId);
}