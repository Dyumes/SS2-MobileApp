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
    userRepository.employers['emp_1'] = Employer(
      id: 'emp_1',
      companyName: 'ACME SA',
      canton: 'VS',
      city: 'Sion',
    );
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

  testWidgets(
    'a loader is shown while the employer is being fetched',
    (tester) => mockNetworkImages(() async {
      await tester.pumpWidget(createCard());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    }),
  );

}
