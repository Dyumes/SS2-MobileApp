import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/models/employer_model.dart';
import 'package:jobinder/widgets/job_details_dialog.dart';

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

  testWidgets('every detail of the offer is listed', (tester) async {
    await tester.pumpWidget(createDialog());
    await tester.pumpAndSettle();

    expect(find.text('Flutter developer'), findsOneWidget);
    expect(find.text('Degree : Bachelor'), findsOneWidget);
    expect(find.text('Hourly salary : 30 CHF'), findsOneWidget);
    expect(find.text('Workload : 50%'), findsOneWidget);
    expect(find.text('Industry : IT'), findsOneWidget);
    expect(find.text('Description : Build a mobile app'), findsOneWidget);
    expect(find.text('Languages : French, English'), findsOneWidget);
    expect(find.text('Start date : 2026-01-15'), findsOneWidget);
    expect(find.text('Deadline : 2026-03-31'), findsOneWidget);
  });

  testWidgets('the yearly salary is derived from the hourly rate and workload',
      (tester) async {
    // 42 h/week x 4 weeks x 12 months x 30 CHF x 50% = 30240 CHF
    await tester.pumpWidget(createDialog());
    await tester.pumpAndSettle();

    expect(find.text('Yearly salary : 30240.00 CHF'), findsOneWidget);
  });

  testWidgets('the journey section falls back when no connection is returned',
      (tester) async {
    // The test HTTP client answers 400, so TransportService returns an empty
    // list. Injecting TransportService would make this deterministic.
    await tester.pumpWidget(createDialog());
    await tester.pumpAndSettle();

    expect(find.text('Time'), findsOneWidget);
    expect(find.text('Journey'), findsOneWidget);
    expect(find.text('No connections found.'), findsOneWidget);
  });
}