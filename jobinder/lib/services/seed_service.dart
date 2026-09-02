import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

//THIS DOC IS GENERATED
class SeedService {
  static const String password = r'Pa$$w0rd';

  static final _db = FirebaseFirestore.instance;
  static final _rng = Random();

  static const _companies = [
    ('Alpine Finance SA', 'ZH', 'Zürich', 'Large (1000+)', 'Finance'),
    ('Helvetia Pharma', 'BS', 'Basel', 'Large (1000+)', 'Pharma'),
    ('Lemanic Consulting', 'GE', 'Genève', 'Medium (200-1000)', 'Consulting'),
    ('Rhone Software', 'VS', 'Sion', 'Startup (<50)', 'IT'),
    ('Bern Health Group', 'BE', 'Bern', 'Medium (200-1000)', 'Healthcare'),
    ('Ticino Energy', 'TI', 'Lugano', 'Small (50-200)', 'Energy'),
  ];

  static const _roles = [
    'Intern', 'Junior', 'Mid-level', 'Senior', 'Lead', 'Manager', 'Director',
  ];
  static const _contracts = ['6 months', '1 year', '2 years', 'Permanent'];
  static const _degrees = [
    'None', 'Apprenticeship', 'Bachelor', 'Master', 'PhD',
  ];
  static const _languages = ['French', 'German', 'English', 'Italian'];

  /// Base hourly rate per seniority level, roughly matching the dataset.
  static const _hourlyByRole = {
    'Intern': 20,
    'Junior': 32,
    'Mid-level': 50,
    'Senior': 74,
    'Lead': 108,
    'Manager': 147,
    'Director': 210,
  };

  static String _emailFor(String companyName) {
    final slug = companyName.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    return 'contact@$slug.ch';
  }

  /// A separate Firebase app, so creating accounts does not sign the current
  /// admin out. The default app keeps its own session untouched.
  static Future<FirebaseApp> _seederApp() async {
    try {
      return Firebase.app('seeder');
    } catch (_) {
      return Firebase.initializeApp(
        name: 'seeder',
        options: Firebase.app().options,
      );
    }
  }

  static const _students = [
    ('Léa', 'Meier', 'Rue de Lausanne 12, Genève', 'Bachelor'),
    ('Noah', 'Schmid', 'Bahnhofstrasse 4, Zürich', 'Master'),
    ('Emma', 'Rossi', 'Via Nassa 8, Lugano', 'Bachelor'),
    ('Liam', 'Favre', 'Avenue de la Gare 21, Sion', 'None'),
    ('Chloé', 'Keller', 'Marktgasse 15, Bern', 'Master'),
    ('Nathan', 'Dubois', 'Rue du Rhône 33, Genève', 'PhD'),
  ];

  static const _skills = [
    'Python', 'Flutter', 'Excel', 'SQL', 'Figma', 'Java', 'Marketing',
    'Data analysis', 'Project management', 'Accounting',
  ];

  static String _studentEmail(String name, String surname) =>
      '${name.toLowerCase()}.${surname.toLowerCase()}@student.ch'
          .replaceAll(RegExp(r'[^a-z.@]'), '');

  /// Creates the Auth account, or recovers its uid if it already exists.
  static Future<String> _account(FirebaseAuth auth, String email) async {
    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') rethrow;
      final cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user!.uid;
    } finally {
      await auth.signOut();
    }
  }

  static Future<void> seed({int jobsPerCompany = 3}) async {
    final app = await _seederApp();
    final auth = FirebaseAuth.instanceFor(app: app);

    var employerCount = 0;
    var jobCount = 0;

    for (final (name, canton, city, size, industry) in _companies) {
      final email = _emailFor(name);
      final employerId = await _account(auth, email);
      employerCount++;

      await _db.collection('user').doc(employerId).set({
        'name': name,
        'surname': '',
        'address': '$city, Switzerland',
        'email': email,
        'role': 'employer',
        'seeded': true,
      });

      await _db.collection('employer').doc(employerId).set({
        'enterprise_name': name,
        'canton': canton,
        'city': city,
        'company_size': size,
        'seeded': true,
      });

      for (var j = 0; j < jobsPerCompany; j++) {
        final role = _roles[_rng.nextInt(_roles.length)];
        final base = _hourlyByRole[role]!;
        final hourly = (base * (0.85 + _rng.nextDouble() * 0.3)).round();

        final langs =
            _languages.where((_) => _rng.nextDouble() < 0.45).toList();
        if (langs.isEmpty) langs.add('English');

        await _db.collection('job_opportunities').add({
          'employer_user': _db.doc('employer/$employerId'),
          'jobName': '$role $industry Specialist',
          'description':
              'Demo offer generated for testing. $role position in $industry '
              'at $name, based in $city.',
          'degree': _degrees[_rng.nextInt(_degrees.length)],
          'languages': langs,
          'salary': hourly,
          'workloadPercentage': [60, 80, 100, 100][_rng.nextInt(4)],
          'industry': industry,
          'role': role,
          'contract': _contracts[_rng.nextInt(_contracts.length)],
          'holidays': 20 + _rng.nextInt(11),
          'timestamp': Timestamp.now(),
          'deadline': Timestamp.fromDate(
            DateTime.now().add(Duration(days: 15 + _rng.nextInt(60))),
          ),
          'student_application': <String, String>{},
          'seeded': true,
        });
        jobCount++;
      }
    }

    var studentCount = 0;

    for (final (name, surname, address, degree) in _students) {
      final email = _studentEmail(name, surname);
      final studentId = await _account(auth, email);
      studentCount++;

      await _db.collection('user').doc(studentId).set({
        'name': name,
        'surname': surname,
        'address': address,
        'email': email,
        'role': 'student',
        'seeded': true,
      });

      final skills = (_skills.toList()..shuffle(_rng)).take(3).toList();

      await _db.collection('student').doc(studentId).set({
        'skills': skills,
        'degree': degree,
        'minSalary': [0, 25, 40, 60][_rng.nextInt(4)],
        'maxDistance': [10, 25, 50, 100][_rng.nextInt(4)],
        'history': [
          {
            'company': _companies[_rng.nextInt(_companies.length)].$1,
            'link': 'https://example.ch',
            'start_date': Timestamp.fromDate(DateTime(2023, 1 + _rng.nextInt(6))),
            'end_date': Timestamp.fromDate(DateTime(2024, 1 + _rng.nextInt(6))),
          },
        ],
        'seeded': true,
      });
    }

    print('Seed done: $employerCount employers, $studentCount students, '
        '$jobCount offers, password "$password"');
  }

  static Future<void> clear() async {
    var deleted = 0;

    for (final collection in [
      'job_opportunities',
      'employer',
      'student',
      'user',
    ]) {
      final snap = await _db
          .collection(collection)
          .where('seeded', isEqualTo: true)
          .get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
        deleted++;
      }
    }
    final app = await _seederApp();
    final auth = FirebaseAuth.instanceFor(app: app);
    var accounts = 0;

    final emails = [
      for (final (name, _, _, _, _) in _companies) _emailFor(name),
      for (final (name, surname, _, _) in _students) _studentEmail(name, surname),
    ];

    for (final email in emails) {
      try {
        final cred = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        await cred.user!.delete();
        accounts++;
      } on FirebaseAuthException {
        // account already gone, nothing to do
      }
    }

    print('Seed cleared: $deleted documents, $accounts accounts');
  }
}