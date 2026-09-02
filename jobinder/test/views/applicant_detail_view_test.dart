import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/models/student_model.dart';
import 'package:jobinder/providers/job_provider.dart';
import 'package:jobinder/view/applicant_detail_view.dart';
import 'package:provider/provider.dart';

import '../fake_repo.dart';
import '../fakes.dart';
import '../helpers/test_asset_bundle.dart';
import '../helpers/test_surface.dart';

void main() {
  late FakeAuthService authService;
  late FakeJobRepository repository;
  late JobProvider jobProvider;

  setUp(() {
    authService = FakeAuthService();
    repository = FakeJobRepository();
    jobProvider = JobProvider(repository)
      ..updateAuth(
        FakeAuthProvider(authService, fakeUser: FakeUser(uid: 'uid_employer_1')),
      );
  });

  tearDown(() {
    repository.dispose();
    authService.dispose();
  });

  Student buildStudent() => Student(
        id: 'uid_student_1',
        skills: const ['Dart', 'Flutter'],
        degree: 'Bachelor',
        minSalary: 4500,
        history: [
          History(
            company: 'ACME SA',
            link: 'https://acme.example',
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2025, 6, 30),
          ),
        ],
      );

  Widget createView({String status = 'applied', Student? student}) {
    return ChangeNotifierProvider<JobProvider>.value(
      value: jobProvider,
      child: MaterialApp(
        home: withTestAssets(
          ApplicantDetailView(
            job: buildJob(id: 'job_1'),
            user: buildAppUser(id: 'uid_student_1'),
            student: student ?? buildStudent(),
            currentStatus: status,
          ),
        ),
      ),
    );
  }

  testWidgets('the applicant profile is displayed', (tester) async {
    useTallSurface(tester);

    await tester.pumpWidget(createView());
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('john@example.com'), findsOneWidget);
    expect(find.text('Dart, Flutter'), findsOneWidget);
    expect(find.text('Bachelor'), findsOneWidget);
    expect(find.text('4500 CHF'), findsOneWidget);
    expect(find.text('30 km'), findsOneWidget);
    expect(find.text('ACME SA'), findsOneWidget);
  });

  testWidgets('an empty profile falls back to readable placeholders',
      (tester) async {
    useTallSurface(tester);

    await tester.pumpWidget(createView(student: Student(id: 'uid_student_1')));
    await tester.pumpAndSettle();

    expect(find.text('No skills listed'), findsOneWidget);
    expect(find.text('No history'), findsOneWidget);
    expect(find.text('Not specified'), findsNWidgets(3));
  });

  testWidgets('the current status is shown in the chip', (tester) async {
    useTallSurface(tester);

    await tester.pumpWidget(createView(status: 'applied'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Chip, 'applied'), findsOneWidget);
  });

  testWidgets('accepting sends the new status and updates the chip',
      (tester) async {
    useTallSurface(tester);

    await tester.pumpWidget(createView());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Accept'));
    await tester.pumpAndSettle();

    final update = repository.statusUpdates.single;
    expect(update.jobId, 'job_1');
    expect(update.userId, 'uid_student_1');
    expect(update.status, 'accepted');

    expect(find.widgetWithText(Chip, 'accepted'), findsOneWidget);
    expect(find.text('Marked as accepted'), findsOneWidget);
  });

  testWidgets('refusing sends the refused status', (tester) async {
    useTallSurface(tester);

    await tester.pumpWidget(createView());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Refuse'));
    await tester.pumpAndSettle();

    expect(repository.statusUpdates.single.status, 'refused');
    expect(find.widgetWithText(Chip, 'refused'), findsOneWidget);
  });

  testWidgets('an accepted applicant can be moved back to pending',
      (tester) async {
    useTallSurface(tester);

    await tester.pumpWidget(createView(status: 'accepted'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Pending'));
    await tester.pumpAndSettle();

    expect(repository.statusUpdates.single.status, 'applied');
    expect(find.widgetWithText(Chip, 'applied'), findsOneWidget);
  });
}