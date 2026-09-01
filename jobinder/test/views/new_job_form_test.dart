import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/providers/job_provider.dart';
import 'package:jobinder/view/new_job_form.dart';
import 'package:provider/provider.dart';

import '../fake_repo.dart';
import '../fakes.dart';
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

  /// Pushes the form on a real route so the `Navigator.pop` at the end of
  /// `_saveJob` has somewhere to go back to. The surface is made tall enough
  /// for the whole form to fit, otherwise the save button sits outside the
  /// render tree and the tap never reaches it.
  Future<void> openForm(WidgetTester tester) async {
    useTallSurface(tester);

    await tester.pumpWidget(
      ChangeNotifierProvider<JobProvider>.value(
        value: jobProvider,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JobForm()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// The form contains, in order: job name, salary, workload, description and
  /// the read-only deadline. The degree and industry pickers are
  /// `DropdownMenu`s, which build a plain `TextField`, so they are not part of
  /// this list.
  Finder fieldAt(int index) => find.byType(TextFormField).at(index);

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Job'));
    await tester.pumpAndSettle();
  }

  Future<void> tickLanguage(WidgetTester tester, String language) async {
    await tester.tap(find.text(language));
    await tester.pump();
  }

  testWidgets('the company name of the connected employer is displayed',
      (tester) async {
    repository.companyName = 'ACME SA';

    await openForm(tester);

    expect(find.text('ACME SA'), findsOneWidget);
  });

  testWidgets('an empty form reports every required field', (tester) async {
    await openForm(tester);

    await tapSave(tester);

    expect(find.text('Please enter a name for the job'), findsOneWidget);
    expect(find.text('Please enter a salary'), findsOneWidget);
    expect(find.text('Please enter a workload percentage'), findsOneWidget);
    expect(find.text('Please enter a description'), findsOneWidget);
    expect(find.text('Please select a deadline'), findsOneWidget);
    expect(repository.addedJobs, isEmpty);
  });

  testWidgets('a non numeric salary is refused', (tester) async {
    await openForm(tester);

    await tester.enterText(fieldAt(1), 'trente');
    await tapSave(tester);

    expect(find.text('Please enter a valid number'), findsOneWidget);
  });

  testWidgets('a workload above 100% is refused', (tester) async {
    await openForm(tester);

    await tester.enterText(fieldAt(2), '150');
    await tapSave(tester);

    expect(
      find.text('Please enter a valid percentage between 0 and 100'),
      findsOneWidget,
    );
  });

  testWidgets('ticking a language box checks it', (tester) async {
    // The language list itself is never rendered, it only feeds the saved
    // offer: that part is asserted in the test below.
    await openForm(tester);

    await tickLanguage(tester, 'French');

    final tile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'French'),
    );
    expect(tile.value, isTrue);
  });

  testWidgets('a complete form creates the offer', (tester) async {
    await openForm(tester);

    await tester.enterText(fieldAt(0), 'Flutter developer');
    await tester.enterText(fieldAt(1), '30');
    await tester.enterText(fieldAt(2), '50');
    await tester.enterText(fieldAt(3), 'Build a mobile app');

    await tickLanguage(tester, 'French');
    await tickLanguage(tester, 'English');

    // The deadline field is read-only: it can only be filled through the
    // date picker, which opens on today's date.
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tapSave(tester);

    final job = repository.addedJobs.single;
    expect(job.jobName, 'Flutter developer');
    expect(job.salary, 30);
    expect(job.workloadPercentage, 50);
    expect(job.description, 'Build a mobile app');
    expect(job.languages, ['French', 'English']);
    expect(repository.lastUserIdUsedForAdd, 'uid_employer_1');

    // The form closed itself once the offer was saved.
    expect(find.byType(JobForm), findsNothing);
  });
}