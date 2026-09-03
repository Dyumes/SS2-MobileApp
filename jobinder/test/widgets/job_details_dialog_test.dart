import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/models/employer_model.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/providers/job_provider.dart';
import 'package:jobinder/widgets/job_details_dialog.dart';
import 'package:provider/provider.dart';

import '../fake_repo.dart';

void main() {
  late FakeUserRepository userRepository;

  setUp(() {
    userRepository = FakeUserRepository();
    userRepository.users['uid_student_1'] = buildAppUser(address: 'Sion');
    userRepository.employers['emp_1'] =
        Employer(id: 'emp_1', companyName: 'ACME SA', canton: 'VD', city: 'Lausanne');
  });

  tearDown(() => userRepository.dispose());

  Widget createDialog() {
    return MaterialApp(
      home: Scaffold(
        body: JobDetailsDialog(
          job: buildJob(
            employerUser: 'emp_1',
            jobName: 'Flutter developer',
            degree: 'Bachelor',
            salary: 30,
            workloadPercentage: 50,
            industry: 'IT',
            description: 'Build a mobile app',
            languages: const ['French', 'English'],
            timestamp: DateTime(2026, 1, 15),
            deadline: DateTime(2026, 3, 31),
          ),
          studentUid: 'uid_student_1',
          userRepository: userRepository,
        ),
      ),
    );
  }

  testWidgets('a loader is shown while the two profiles are fetched',
      (tester) async {
    await tester.pumpWidget(createDialog());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}