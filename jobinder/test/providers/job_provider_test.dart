import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/providers/job_provider.dart';

import '../fake_repo.dart';
import '../fakes.dart';

void main() {
  late FakeAuthService authService;
  late FakeJobRepository repository;
  late JobProvider provider;

  setUp(() {
    authService = FakeAuthService();
    repository = FakeJobRepository();
    provider = JobProvider(repository);
  });

  tearDown(() {
    repository.dispose();
    authService.dispose();
  });

  void connect({String uid = 'uid_employer_1'}) {
    provider.updateAuth(
      FakeAuthProvider(authService, fakeUser: FakeUser(uid: uid)),
    );
  }

  group('reading offers', () {
    test('a student sees every published offer', () async {
      repository.emitJobs([buildJob(id: 'job_1'), buildJob(id: 'job_2')]);

      final jobs = await provider.studentjobs.first;

      expect(jobs, hasLength(2));
    });

    test('an employer only queries their own offers', () async {
      connect(uid: 'uid_employer_1');
      repository.emitJobs([buildJob()]);

      await provider.jobs.first;

      expect(repository.lastEmployerIdQueried, 'uid_employer_1');
    });

    test('a logged out user queries with an empty employer id', () async {
      await provider.jobs.first;

      expect(repository.lastEmployerIdQueried, isEmpty);
    });
  });

  group('creating and updating an offer', () {
    test('addJob forwards the offer with the connected uid', () async {
      connect(uid: 'uid_employer_1');

      await provider.addJob(buildJob(jobName: 'Data analyst'));

      expect(repository.addedJobs.single.jobName, 'Data analyst');
      expect(repository.lastUserIdUsedForAdd, 'uid_employer_1');
    });

    test('addJob is ignored when nobody is logged in', () async {
      await provider.addJob(buildJob());

      expect(repository.addedJobs, isEmpty);
    });

    test('updateJob is ignored when nobody is logged in', () async {
      await provider.updateJob(buildJob());

      expect(repository.updatedJobs, isEmpty);
    });
  });

  group('deleting an offer', () {
    test('the employer document is resolved before deleting', () async {
      connect();
      repository.employerUserId = 'emp_42';

      await provider.deleteJob('job_1');

      expect(repository.deletedJobIds, ['job_1']);
      expect(repository.lastUserIdUsedForDelete, 'emp_42');
    });

    test('the employer document is only resolved once', () async {
      connect();

      await provider.deleteJob('job_1');
      await provider.deleteJob('job_2');

      expect(repository.getEmployerUserIdCalls, 1);
    });

    test('the cache is dropped when the connected user changes', () async {
      connect(uid: 'uid_employer_1');
      await provider.deleteJob('job_1');

      connect(uid: 'uid_employer_2');
      await provider.deleteJob('job_2');

      expect(repository.getEmployerUserIdCalls, 2);
    });

    test('nothing is deleted when the user has no employer document', () async {
      connect();
      repository.employerUserId = null;

      await provider.deleteJob('job_1');

      expect(repository.deletedJobIds, isEmpty);
    });
  });

  group('applications', () {
    test('updateStatus forwards the new status and notifies listeners', () async {
      var notified = 0;
      provider.addListener(() => notified++);

      await provider.updateStatus('job_1', 'uid_student_1', 'accepted');

      final update = repository.statusUpdates.single;
      expect(update.jobId, 'job_1');
      expect(update.userId, 'uid_student_1');
      expect(update.status, 'accepted');
      expect(notified, 1);
    });
  });

  group('company name', () {
    test('currentCompanyName resolves the employer then reads its name', () async {
      connect();
      repository.companyName = 'ACME SA';

      expect(await provider.currentCompanyName(), 'ACME SA');
    });

    test('currentCompanyName is null without an employer document', () async {
      connect();
      repository.employerUserId = null;

      expect(await provider.currentCompanyName(), isNull);
    });
  });
}