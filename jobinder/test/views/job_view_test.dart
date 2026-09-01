import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/providers/job_provider.dart';
import 'package:jobinder/view/homepage_employer.dart';
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
      fakeUser: FakeUser(uid: 'uid_employer_1'),
    );
    repository = FakeJobRepository();
    jobProvider = JobProvider(repository)..updateAuth(authProvider);
  });

  tearDown(() {
    repository.dispose();
    authService.dispose();
  });

  Widget createJobView() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<JobProvider>.value(value: jobProvider),
      ],
      child: const MaterialApp(home: HomePageEmployer()),
    );
  }

  testWidgets('the employer sees each of their offers', (tester) async {
    repository.emitJobs([
      buildJob(id: 'job_1', jobName: 'Flutter developer', description: 'Mobile app'),
      buildJob(id: 'job_2', jobName: 'Data analyst', description: 'Dashboards'),
    ]);

    await tester.pumpWidget(createJobView());
    await tester.pumpAndSettle();

    expect(find.text('Flutter developer'), findsOneWidget);
    expect(find.text('Data analyst'), findsOneWidget);
    expect(find.text('Dashboards'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'New job offer'), findsOneWidget);
  });

  testWidgets('an employer without offers still sees the create button',
      (tester) async {
    await tester.pumpWidget(createJobView());
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);
    expect(find.widgetWithText(ElevatedButton, 'New job offer'), findsOneWidget);
  });

  testWidgets('deleting asks for confirmation first', (tester) async {
    repository.emitJobs([buildJob(id: 'job_1', jobName: 'Flutter developer')]);

    await tester.pumpWidget(createJobView());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete this offer?'), findsOneWidget);
    expect(repository.deletedJobIds, isEmpty);
  });

  testWidgets('cancelling the dialog keeps the offer', (tester) async {
    repository.emitJobs([buildJob(id: 'job_1')]);

    await tester.pumpWidget(createJobView());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this offer?'), findsNothing);
    expect(repository.deletedJobIds, isEmpty);
  });

  testWidgets('confirming deletes the offer', (tester) async {
    repository.employerUserId = 'emp_42';
    repository.emitJobs([buildJob(id: 'job_1')]);

    await tester.pumpWidget(createJobView());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repository.deletedJobIds, ['job_1']);
    expect(repository.lastUserIdUsedForDelete, 'emp_42');
  });
}