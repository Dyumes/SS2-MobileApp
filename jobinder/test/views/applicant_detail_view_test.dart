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
}