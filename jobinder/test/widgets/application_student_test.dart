// Requires application_student.dart to read the uid from AuthProvider
// instead of FirebaseAuth.instance:
//   final studentUid = context.watch<AuthProvider>().user?.uid;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/providers/job_provider.dart';
import 'package:jobinder/widgets/application_student.dart';
import 'package:provider/provider.dart';

import '../fake_repo.dart';
import '../fakes.dart';

void main() {
  late FakeAuthService authService;
  late FakeAuthProvider authProvider;
  late FakeJobRepository repository;
  late JobProvider jobProvider;

  setUp(() {
    authService = FakeAuthService();
    authProvider = FakeAuthProvider(
      authService,
      fakeUser: FakeUser(uid: 'uid_student_1'),
    );
    repository = FakeJobRepository();
    jobProvider = JobProvider(repository)..updateAuth(authProvider);
  });

  tearDown(() {
    repository.dispose();
    authService.dispose();
  });

  Widget createList({required String status, AuthProvider? auth}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth ?? authProvider),
        ChangeNotifierProvider<JobProvider>.value(value: jobProvider),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ApplicationsList(status: status)),
        ),
      ),
    );
  }

  void seedApplications() {
    repository.emitJobs([
      buildJob(
        id: 'job_1',
        jobName: 'Flutter developer',
        studentApplication: const {'uid_student_1': 'applied'},
      ),
      buildJob(
        id: 'job_2',
        jobName: 'Data analyst',
        studentApplication: const {'uid_student_1': 'accepted'},
      ),
      buildJob(
        id: 'job_3',
        jobName: 'Not mine',
        studentApplication: const {'uid_other': 'applied'},
      ),
    ]);
  }
}