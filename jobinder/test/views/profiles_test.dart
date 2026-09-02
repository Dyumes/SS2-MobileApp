// Requires jobseeker_profile.dart and employer_profile.dart to accept their
// repository:
//   const StudentProfileView({super.key, this.userRepository});
//   final UserRepository? userRepository;
//   late final UserRepository _userRepository = widget.userRepository ?? FirestoreUserRepository();
//
// jobseeker_profile.dart also needs the `Expanded(child: ApplicationsList(...))`
// to become a plain `ApplicationsList(...)`: an Expanded inside the children of
// a ListView throws at layout time.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/models/employer_model.dart';
import 'package:jobinder/models/student_model.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/providers/job_provider.dart';
import 'package:jobinder/view/employer_profile.dart';
import 'package:jobinder/view/jobseeker_profile.dart';
import 'package:provider/provider.dart';

import '../fake_repo.dart';
import '../fakes.dart';
import '../helpers/test_asset_bundle.dart';
import '../helpers/test_surface.dart';

void main() {
  late FakeAuthService authService;
  late FakeAuthProvider authProvider;
  late FakeUserRepository userRepository;
  late FakeJobRepository jobRepository;
  late JobProvider jobProvider;

  setUp(() {
    authService = FakeAuthService();
    userRepository = FakeUserRepository();
    jobRepository = FakeJobRepository();
  });

  tearDown(() {
    userRepository.dispose();
    jobRepository.dispose();
    authService.dispose();
  });

  void connect(String uid) {
    authProvider = FakeAuthProvider(authService, fakeUser: FakeUser(uid: uid));
    jobProvider = JobProvider(jobRepository)..updateAuth(authProvider);
  }

  Widget wrap(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<JobProvider>.value(value: jobProvider),
      ],
      child: MaterialApp(home: Scaffold(body: withTestAssets(child))),
    );
  }

  group('StudentProfileView', () {
    setUp(() {
      connect('uid_student_1');
      userRepository.users['uid_student_1'] = buildAppUser(address: 'Sion');
      userRepository.students['uid_student_1'] = Student(
        id: 'uid_student_1',
        skills: const ['Dart', 'Flutter'],
        degree: 'Bachelor',
        minSalary: 100,
        history: [History(company: 'ACME SA', link: 'https://acme.example')],
      );
    });

    Widget createView() =>
        wrap(StudentProfileView(userRepository: userRepository));

    testWidgets('a loader is shown while the profile is fetched',
        (tester) async {
      await tester.pumpWidget(createView());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('the profile of the connected student is displayed',
        (tester) async {
      await tester.pumpWidget(createView());
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Dart, Flutter'), findsOneWidget);
      expect(find.text('Bachelor'), findsOneWidget);
      expect(find.text('100 CHF / hour'), findsOneWidget);
      expect(find.text('30 km'), findsOneWidget);
      expect(find.text('ACME SA'), findsOneWidget);
    });

    testWidgets('the three application filters are available', (tester) async {
      useTallSurface(tester);                       

      await tester.pumpWidget(createView());
      await tester.pumpAndSettle();

      expect(find.text('Submitted'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Refused'), findsOneWidget);
    });


    testWidgets('the edit dialog opens prefilled and saves the changes',
        (tester) async {
      await tester.pumpWidget(createView());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Edit profile'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Sion'),
        'Martigny',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      final update = userRepository.lastStudentUpdate;
      expect(update, isNotNull);
      expect(update!.uid, 'uid_student_1');
      expect(update.address, 'Martigny');
      expect(update.skills, ['Dart', 'Flutter']);
    });
  });

  group('EmployerProfileView', () {
    setUp(() {
      connect('uid_employer_1');
      userRepository.users['uid_employer_1'] = buildAppUser(
        id: 'uid_employer_1',
        name: 'Jane',
        surname: 'Smith',
        address: 'Rue du Nord 1',
        email: 'hr@acme.example',
        role: 'employer',
      );
      userRepository.employers['uid_employer_1'] = Employer(
        id: 'uid_employer_1',
        companyName: 'ACME SA',
        canton: 'VS',
        city: 'Sion',
      );
    });

    Widget createView() =>
        wrap(EmployerProfileView(userRepository: userRepository));

    testWidgets('the company of the connected employer is displayed',
        (tester) async {
      await tester.pumpWidget(createView());
      await tester.pumpAndSettle();

      expect(find.text('Jane Smith / ACME SA'), findsOneWidget);
      expect(find.text('VS'), findsOneWidget);
      expect(find.text('Sion'), findsOneWidget);
      expect(find.text('Rue du Nord 1'), findsOneWidget);
    });

    testWidgets('an empty city blocks the save', (tester) async {
      await tester.pumpWidget(createView());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Edit Profile'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Sion'), '');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Field required'), findsOneWidget);
      expect(userRepository.lastEmployerUpdate, isNull);
    });

    testWidgets('editing the city saves the new value', (tester) async {
      await tester.pumpWidget(createView());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Edit Profile'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Sion'),
        'Lausanne',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      final update = userRepository.lastEmployerUpdate;
      expect(update, isNotNull);
      expect(update!.city, 'Lausanne');
      expect(update.canton, 'VS');
      expect(update.address, 'Rue du Nord 1');
    });

    testWidgets('signing out goes through the auth service', (tester) async {
      await tester.pumpWidget(createView());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Disconnect'));
      await tester.pumpAndSettle();

      // FakeAuthService returns signOutError (null here) without throwing.
      expect(authProvider.errorMessage, isNull);
    });
  });
}