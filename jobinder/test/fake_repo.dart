import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/models/employer_model.dart';
import 'package:jobinder/models/job_opportunities_model.dart';
import 'package:jobinder/models/student_model.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/repositories/job_repository.dart';
import 'package:jobinder/repositories/user_repository.dart';
import 'package:jobinder/services/auth_service.dart';

class FakeUser implements User {
  FakeUser({this.uid = 'uid_student_1', this.email = 'user@example.com'});

  @override
  
  final String uid;

  @override
  final String? email;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        '${invocation.memberName} is not implemented on FakeUser',
      );
}

class FakeAuthProvider extends AuthProvider {
  FakeAuthProvider(
    AuthService authService, {
    this.fakeUser,
    this.fakeAppUser,
  }) : super(authService);

  final User? fakeUser;
  final AppUser? fakeAppUser;

  @override
  User? get user => fakeUser;

  @override
  AppUser? get appUser => fakeAppUser;
}

/// In-memory [JobRepository] that records every write it receives.
class FakeJobRepository implements JobRepository {
  FakeJobRepository({List<JobOpportunities>? jobs}) : _jobs = [...?jobs];

  final List<JobOpportunities> _jobs;
  final StreamController<List<JobOpportunities>> _controller =
      StreamController<List<JobOpportunities>>.broadcast();

  /// Value returned by [getEmployerUserId]; set it to null to simulate a user
  /// that has no employer document.
  String? employerUserId = 'emp_1';
  String companyName = 'ACME SA';
  String companyCanton = 'VS';
  String companySize = 'Small (50-200)';

  final List<JobOpportunities> addedJobs = [];
  final List<JobOpportunities> updatedJobs = [];
  final List<String> deletedJobIds = [];
  final List<StatusUpdate> statusUpdates = [];

  int getEmployerUserIdCalls = 0;
  String? lastEmployerIdQueried;
  String? lastUserIdUsedForAdd;
  String? lastUserIdUsedForDelete;


  @override
  Future<String> getCompanyName(String? ref) async => companyName;

  @override
  Future<String> getCompanyCanton(String? ref) async => companyCanton;

  @override
  Future<String> getCompanySize(String? ref) async => companySize;

  /// Pushes a new snapshot to every open stream.
  void emitJobs(List<JobOpportunities> jobs) {
    _jobs
      ..clear()
      ..addAll(jobs);
    _controller.add(List.of(_jobs));
  }

  Stream<List<JobOpportunities>> _snapshots() async* {
    yield List.of(_jobs);
    yield* _controller.stream;
  }

  @override
  Stream<List<JobOpportunities>> watchJobs() => _snapshots();

  @override
  Stream<List<JobOpportunities>> watchJobsByEmployer(String employerId) {
    lastEmployerIdQueried = employerId;
    return _snapshots();
  }

  @override
  Future<void> addJob(JobOpportunities job, String userId) async {
    addedJobs.add(job);
    lastUserIdUsedForAdd = userId;
  }

  @override
  Future<void> updateJob(JobOpportunities job, String userId) async {
    updatedJobs.add(job);
  }

  @override
  Future<void> deleteJob(String jobId, String userId) async {
    deletedJobIds.add(jobId);
    lastUserIdUsedForDelete = userId;
  }

  @override
  Future<String?> getEmployerUserId(String uid) async {
    getEmployerUserIdCalls++;
    return employerUserId;
  }

  @override
  Future<void> updateStatus(String jobId, String userId, String status) async {
    statusUpdates.add(StatusUpdate(jobId, userId, status));
  }

  void dispose() => _controller.close();
}

/// One call to [FakeJobRepository.updateStatus].
class StatusUpdate {
  const StatusUpdate(this.jobId, this.userId, this.status);

  final String jobId;
  final String userId;
  final String status;

  @override
  String toString() => 'StatusUpdate($jobId, $userId, $status)';
}

/// In-memory [UserRepository].
class FakeUserRepository implements UserRepository {
  final Map<String, AppUser> users = {};
  final Map<String, Student> students = {};
  final Map<String, Employer> employers = {};

  final List<AppUser> addedUsers = [];
  StudentProfileUpdate? lastStudentUpdate;
  EmployerProfileUpdate? lastEmployerUpdate;

  final StreamController<List<AppUser>> _usersController =
      StreamController<List<AppUser>>.broadcast();

  void emitUsers(List<AppUser> list) => _usersController.add(list);

  @override
  Stream<List<AppUser>> watchUsers() async* {
    yield users.values.toList();
    yield* _usersController.stream;
  }

  @override
  Future<void> addStudentUser(AppUser user, Student student, String userId) async {
    users[userId] = user;
    students[userId] = student;
    addedUsers.add(user);
  }

  @override
  Future<void> addEmployerUser(AppUser user, Employer employer, String userId) async {
    users[userId] = user;
    employers[userId] = employer;
    addedUsers.add(user);
  }

  @override
  Future<Employer?> getEmployerByUid(String uid) async => employers[uid];

  @override
  Future<Student?> getStudentByUid(String uid) async => students[uid];

  @override
  Future<AppUser?> getUser(String uid) async => users[uid];

  @override
  Future<void> updateStudentProfile(
    String uid, {
    required String address,
    required List<String> skills,
    required List<History> history,
    String? degree,
    int? minSalary,
    String? industry,
  }) async {
    lastStudentUpdate = StudentProfileUpdate(
      uid: uid,
      address: address,
      skills: skills,
      history: history,
      degree: degree,
      minSalary: minSalary,
      industry: industry,
    );
  }

  @override
  Future<void> updateEmployerProfile(
    String uid, {
    required String address,
    required String canton,
    required String city,
    required String companySize,
  }) async {
    lastEmployerUpdate = EmployerProfileUpdate(
      uid: uid,
      address: address,
      canton: canton,
      city: city,
      companySize: companySize,
    );
  }

  void dispose() => _usersController.close();
}

class StudentProfileUpdate {
  const StudentProfileUpdate({
    required this.uid,
    required this.address,
    required this.skills,
    required this.history,
    this.degree,
    this.minSalary,
    this.industry,
  });

  final String uid;
  final String address;
  final List<String> skills;
  final List<History> history;
  final String? degree;
  final int? minSalary;
  final String? industry;
}

class EmployerProfileUpdate {
  const EmployerProfileUpdate({
    required this.uid,
    required this.address,
    required this.canton,
    required this.city,
    required this.companySize,
  });

  final String uid;
  final String address;
  final String canton;
  final String city;
  final String companySize;
}

/// Convenience builder so tests only spell out the fields they care about.
JobOpportunities buildJob({
  String id = 'job_1',
  String employerUser = 'emp_1',
  String degree = 'Bachelor',
  String jobName = 'Flutter developer',
  String description = 'Build a mobile app',
  List<String> languages = const ['French'],
  int salary = 30,
  int workloadPercentage = 50,
  String industry = 'IT',
  String role = 'Junior',
  String contract = 'Permanent',
  int holidays = 25,
  DateTime? timestamp,
  DateTime? deadline,
  Map<String, String> studentApplication = const {},
}) {
  return JobOpportunities(
    id: id,
    employer_user: employerUser,
    degree: degree,
    jobName: jobName,
    description: description,
    languages: languages,
    salary: salary,
    workloadPercentage: workloadPercentage,
    industry: industry,
    role: role,
    contract: contract,
    holidays: holidays,
    timestamp: timestamp ?? DateTime(2026, 1, 15),
    deadline: deadline ?? DateTime(2026, 3, 31),
    studentApplication: studentApplication,
  );
}

AppUser buildAppUser({
  String id = 'uid_student_1',
  String name = 'John',
  String surname = 'Doe',
  String address = 'Sion',
  String email = 'john@example.com',
  String role = 'student',
}) {
  return AppUser(
    id: id,
    name: name,
    surname: surname,
    address: address,
    email: email,
    role: role,
  );
}