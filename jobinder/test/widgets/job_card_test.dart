import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/models/employer_model.dart';
import 'package:jobinder/widgets/job_card.dart';

import '../fake_repo.dart';
import '../helpers/mock_network_images.dart';

void main() {
  late FakeUserRepository userRepository;

  setUp(() {
    userRepository = FakeUserRepository();

    // The employer document and the AppUser behind it.
    userRepository.employers['emp_1'] =
        Employer(id: 'emp_1', companyName: 'ACME SA', canton: 'VS', city: 'Sion');
    userRepository.users['emp_1'] = buildAppUser(
      id: 'emp_1',
      name: 'Jane',
      surname: 'Smith',
      address: 'Rue du Nord 1',
      email: 'hr@acme.example',
      role: 'employer',
    );

    // The student looking at the card.
    userRepository.users['uid_student_1'] = buildAppUser();
  });

  tearDown(() => userRepository.dispose());

  Widget createCard({Map<String, String>? languages}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            height: 560,
            child: JobCard(
              job: buildJob(
                employerUser: 'emp_1',
                jobName: 'Flutter developer',
                degree: 'Bachelor',
                salary: 30,
                industry: 'IT',
                languages: const ['French', 'English'],
              ),
              studentUid: 'uid_student_1',
              userRepository: userRepository,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('a loader is shown while the employer is being fetched',
      (tester) => mockNetworkImages(() async {
            await tester.pumpWidget(createCard());

            expect(find.byType(CircularProgressIndicator), findsOneWidget);
          }));

  testWidgets('the card shows the offer and its employer',
      (tester) => mockNetworkImages(() async {
            await tester.pumpWidget(createCard());
            await tester.pumpAndSettle();

            expect(find.text('Flutter developer'), findsOneWidget);
            expect(find.text('Bachelor'), findsOneWidget);
            expect(find.text('30 CHF'), findsOneWidget);
            expect(find.text('IT'), findsOneWidget);
            expect(find.text('hr@acme.example'), findsOneWidget);
            expect(find.text('Rue du Nord 1, Sion (VS)'), findsOneWidget);
          }));

  testWidgets('each language gets its own badge',
      (tester) => mockNetworkImages(() async {
            await tester.pumpWidget(createCard());
            await tester.pumpAndSettle();

            expect(find.text('French'), findsOneWidget);
            expect(find.text('English'), findsOneWidget);
          }));

  testWidgets('an unknown employer shows the error card',
      (tester) => mockNetworkImages(() async {
            userRepository.employers.remove('emp_1');

            await tester.pumpWidget(createCard());
            await tester.pumpAndSettle();

            expect(find.text('Error loading job details'), findsOneWidget);
            expect(find.text('Flutter developer'), findsNothing);
          }));
}