import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/models/employer_model.dart';
import 'package:jobinder/models/job_opportunities_model.dart';
import 'package:jobinder/models/student_model.dart';
import 'package:jobinder/models/transport.dart';

void main() {
  group('AppUser', () {
    test('fromMap reads every field and takes the id from the document', () {
      final user = AppUser.fromMap(const {
        'name': 'John',
        'surname': 'Doe',
        'address': 'Rue du Nord 1, Sion',
        'email': 'john@example.com',
        'role': 'student',
      }, 'usr_1');

      expect(user.id, 'usr_1');
      expect(user.name, 'John');
      expect(user.surname, 'Doe');
      expect(user.address, 'Rue du Nord 1, Sion');
      expect(user.email, 'john@example.com');
      expect(user.role, 'student');
    });

    test('fromMap falls back to empty strings on a partial document', () {
      final user = AppUser.fromMap(const {'name': 'John'}, 'usr_1');

      expect(user.surname, isEmpty);
      expect(user.address, isEmpty);
      expect(user.email, isEmpty);
      expect(user.role, isEmpty);
    });

    test('toMap never writes the id back into the document', () {
      final map = AppUser(
        id: 'usr_1',
        name: 'John',
        surname: 'Doe',
        address: 'Sion',
        email: 'john@example.com',
        role: 'student',
      ).toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map, hasLength(5));
    });
  });

  group('Employer', () {
    test('survives a toMap / fromMap round trip', () {
      final employer = Employer(
        companyName: 'ACME SA',
        canton: 'VS',
        city: 'Sion',
      );

      final restored = Employer.fromMap(employer.toMap(), 'emp_1');

      expect(restored.id, 'emp_1');
      expect(restored.companyName, 'ACME SA');
      expect(restored.canton, 'VS');
      expect(restored.city, 'Sion');
    });

    test('company name is stored under the enterprise_name key', () {
      // FirestoreJobRepository.getCompanyName currently reads
      // 'entreprise_name' (French spelling): this test documents the key that
      // is actually written, so the mismatch shows up here.
      final map = Employer(companyName: 'ACME SA', canton: 'VS', city: 'Sion')
          .toMap();

      expect(map['enterprise_name'], 'ACME SA');
    });
  });

  group('Student', () {
    test('fromMap parses skills and work history', () {
      final student = Student.fromMap({
        'skills': ['Dart', 'Flutter'],
        'history': [
          {
            'company': 'ACME SA',
            'link': 'https://acme.example',
            'start_date': Timestamp.fromDate(DateTime(2024, 1, 1)),
            'end_date': Timestamp.fromDate(DateTime(2025, 6, 30)),
          },
        ],
        'degree': 'Bachelor',
        'minSalary': 4500,
      }, 'std_1');

      expect(student.id, 'std_1');
      expect(student.skills, ['Dart', 'Flutter']);
      expect(student.history, hasLength(1));
      expect(student.history!.single.company, 'ACME SA');
      expect(student.history!.single.startDate, DateTime(2024, 1, 1));
      expect(student.history!.single.endDate, DateTime(2025, 6, 30));
      expect(student.degree, 'Bachelor');
      expect(student.minSalary, 4500);
    });

    test('fromMap tolerates a brand new profile with no data', () {
      final student = Student.fromMap(const {}, 'std_1');

      expect(student.skills, isEmpty);
      expect(student.history, isEmpty);
      expect(student.degree, isNull);
      expect(student.minSalary, isNull);
    });

    test('an ongoing job keeps a null end date', () {
      final history = History.fromMap({
        'company': 'ACME SA',
        'link': 'https://acme.example',
        'start_date': Timestamp.fromDate(DateTime(2025, 9, 1)),
      });

      expect(history.startDate, DateTime(2025, 9, 1));
      expect(history.endDate, isNull);
      expect(history.toMap()['end_date'], isNull);
    });
  });

  group('JobOpportunities', () {
    Map<String, dynamic> firestoreJob() => {
          'degree': 'Bachelor',
          'jobName': 'Flutter developer',
          'description': 'Build a mobile app',
          'languages': ['French', 'English'],
          'salary': 30,
          'workloadPercentage': 50,
          'industry': 'IT',
          'timestamp': Timestamp.fromDate(DateTime(2026, 1, 15)),
          'deadline': Timestamp.fromDate(DateTime(2026, 3, 31)),
          'student_application': {'uid_1': 'applied', 'uid_2': 'accepted'},
        };

    test('fromMap converts timestamps and applications', () {
      final job = JobOpportunities.fromMap(firestoreJob(), 'job_1');

      expect(job.id, 'job_1');
      expect(job.jobName, 'Flutter developer');
      expect(job.languages, ['French', 'English']);
      expect(job.salary, 30);
      expect(job.workloadPercentage, 50);
      expect(job.timestamp, DateTime(2026, 1, 15));
      expect(job.deadline, DateTime(2026, 3, 31));
      expect(job.studentApplication['uid_2'], 'accepted');
    });

    test('a job without applications yields an empty map', () {
      final data = firestoreJob()..remove('student_application');

      expect(JobOpportunities.fromMap(data, 'job_1').studentApplication, isEmpty);
    });

    test('employer_user is empty when the reference is missing', () {
      expect(JobOpportunities.fromMap(firestoreJob(), 'job_1').employer_user, isEmpty);
    });

    test('toMap writes the applications under student_application', () {
      final map = JobOpportunities.fromMap(firestoreJob(), 'job_1').toMap();

      expect(map['student_application'], {'uid_1': 'applied', 'uid_2': 'accepted'});
      expect(map['timestamp'], isA<Timestamp>());
      expect(map.containsKey('id'), isFalse);
    });

    test('copyWith only replaces the given fields', () {
      final job = JobOpportunities.fromMap(firestoreJob(), 'job_1');

      final updated = job.copyWith(salary: 45, jobName: 'Senior developer');

      expect(updated.salary, 45);
      expect(updated.jobName, 'Senior developer');
      expect(updated.id, job.id);
      expect(updated.description, job.description);
      expect(updated.deadline, job.deadline);
      expect(updated.studentApplication, job.studentApplication);
    });
  });

  group('Transport', () {
    test('a walking section is labelled Walk', () {
      final transport = Transport.fromMap({
        'from': {'departure': '2026-01-15T08:00:00+0100'},
        'to': {'arrival': '2026-01-15T08:45:00+0100'},
        'sections': [
          {
            'walk': {'duration': 300},
            'departure': {
              'station': {'name': 'Sion, gare'},
              'departure': '2026-01-15T08:00:00+0100',
            },
            'arrival': {
              'station': {'name': 'Sion'},
              'arrival': '2026-01-15T08:05:00+0100',
            },
          },
        ],
      });

      expect(transport.sections.single['type'], 'Walk');
      expect(transport.sections.single['departureStation'], 'Sion, gare');
    });

    test('a train section shows its category and number', () {
      final transport = Transport.fromMap({
        'from': {'departure': '2026-01-15T08:10:00+0100'},
        'to': {'arrival': '2026-01-15T09:00:00+0100'},
        'sections': [
          {
            'journey': {'category': 'IR', 'number': '90'},
            'departure': {
              'station': {'name': 'Sion'},
              'departure': '2026-01-15T08:10:00+0100',
              'platform': '3',
            },
            'arrival': {
              'station': {'name': 'Lausanne'},
              'arrival': '2026-01-15T09:00:00+0100',
              'platform': '5',
            },
          },
        ],
      });

      final section = transport.sections.single;
      expect(section['type'], 'IR 90');
      expect(section['departurePlatform'], '3');
      expect(section['arrivalStation'], 'Lausanne');
    });

    test('an empty connection produces no section', () {
      expect(Transport.fromMap(const {}).sections, isEmpty);
    });
  });
}