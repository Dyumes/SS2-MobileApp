// Requires homepage_student.dart to accept its repositories:
//   const HomePageStudent({super.key, this.jobRepository, this.userRepository});
//   final JobRepository? jobRepository;
//   final UserRepository? userRepository;
// and in the State:
//   late final JobRepository _jobRepository = widget.jobRepository ?? FirestoreJobRepository();
//   late final UserRepository _userRepository = widget.userRepository ?? FirestoreUserRepository();
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/models/employer_model.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/providers/job_provider.dart';
import 'package:jobinder/view/homepage_student.dart';
import 'package:provider/provider.dart';
import 'package:jobinder/models/student_model.dart';

import '../fake_repo.dart';
import '../fakes.dart';
import '../helpers/mock_network_images.dart';

void main() {
  late FakeAuthService authService;
  late FakeAuthProvider authProvider;
  late FakeJobRepository jobRepository;
  late FakeUserRepository userRepository;
  late JobProvider jobProvider;

  setUp(() {
    authService = FakeAuthService();
    authProvider = FakeAuthProvider(
      authService,
      fakeUser: FakeUser(uid: 'uid_student_1'),
    );

    jobRepository = FakeJobRepository();
    jobProvider = JobProvider(jobRepository)..updateAuth(authProvider);

    userRepository = FakeUserRepository();

    // dans setUp, à côté des users existants :
    userRepository.students['uid_student_1'] = Student(
      id: 'uid_student_1',
      skills: const ['Dart', 'Flutter'],
      degree: 'Bachelor',
      minSalary: 4500,
      history: const [],
    );
    userRepository.users['emp_1'] = buildAppUser(
      id: 'emp_1',
      name: 'Jane',
      surname: 'Smith',
      email: 'hr@acme.example',
      role: 'employer',
    );
    userRepository.employers['emp_1'] = Employer(
      id: 'emp_1',
      companyName: 'ACME SA',
      canton: 'VS',
      city: 'Sion',
    );
  });

  tearDown(() {
    jobRepository.dispose();
    userRepository.dispose();
    authService.dispose();
  });

  Widget createHomePage() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<JobProvider>.value(value: jobProvider),
      ],
      child: MaterialApp(
        home: HomePageStudent(
          jobRepository: jobRepository,
          userRepository: userRepository,
        ),
      ),
    );
  }

  // void seedJobs() {
  //   jobRepository.emitJobs([
  //     buildJob(id: 'job_1', employerUser: 'emp_1', jobName: 'Flutter developer'),
  //     buildJob(id: 'job_2', employerUser: 'emp_1', jobName: 'Data analyst'),
  //   ]);
  // }

  testWidgets('with no offer left the deck is empty',
      (tester) => mockNetworkImages(() async {
            await tester.pumpWidget(createHomePage());
            await tester.pumpAndSettle();

            expect(find.text('Nothing'), findsOneWidget);
          }));

  testWidgets('an offer already applied to is never shown again',
      (tester) => mockNetworkImages(() async {
            jobRepository.emitJobs([
              buildJob(
                id: 'job_1',
                employerUser: 'emp_1',
                jobName: 'Flutter developer',
                studentApplication: const {'uid_student_1': 'applied'},
              ),
            ]);

            await tester.pumpWidget(createHomePage());
            await tester.pumpAndSettle();

            expect(find.text('Nothing'), findsOneWidget);
          }));

}