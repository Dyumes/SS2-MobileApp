import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/models/appuser_model.dart';

void main() {
  test('constructor sets all fields correctly', () {
    final user = AppUser(
      id: 'user1',
      name: 'John',
      surname: 'Doe',
      address: 'Main Street 10',
      email: 'john@example.com',
      role: 'student',
    );

    expect(user.id, 'user1');
    expect(user.name, 'John');
    expect(user.surname, 'Doe');
    expect(user.address, 'Main Street 10');
    expect(user.email, 'john@example.com');
    expect(user.role, 'student');
  });

  test('constructor uses an empty string as default id', () {
    final user = AppUser(
      name: 'John',
      surname: 'Doe',
      address: 'Main Street 10',
      email: 'john@example.com',
      role: 'student',
    );

    expect(user.id, '');
  });

  test('toMap includes all user fields except id', () {
    final user = AppUser(
      id: 'user1',
      name: 'John',
      surname: 'Doe',
      address: 'Main Street 10',
      email: 'john@example.com',
      role: 'student',
    );

    final map = user.toMap();

    expect(map['name'], 'John');
    expect(map['surname'], 'Doe');
    expect(map['address'], 'Main Street 10');
    expect(map['email'], 'john@example.com');
    expect(map['role'], 'student');

    expect(map.containsKey('id'), false);
  });

  test('fromMap reads all fields correctly', () {
    final user = AppUser.fromMap(
      {
        'name': 'John',
        'surname': 'Doe',
        'address': 'Main Street 10',
        'email': 'john@example.com',
        'role': 'student',
      },
      'user1',
    );

    expect(user.id, 'user1');
    expect(user.name, 'John');
    expect(user.surname, 'Doe');
    expect(user.address, 'Main Street 10');
    expect(user.email, 'john@example.com');
    expect(user.role, 'student');
  });

  test('fromMap uses empty strings for missing fields', () {
    final user = AppUser.fromMap(
      {},
      'user1',
    );

    expect(user.id, 'user1');
    expect(user.name, '');
    expect(user.surname, '');
    expect(user.address, '');
    expect(user.email, '');
    expect(user.role, '');
  });

  test('fromMap uses empty strings for null fields', () {
    final user = AppUser.fromMap(
      {
        'name': null,
        'surname': null,
        'address': null,
        'email': null,
        'role': null,
      },
      'user1',
    );

    expect(user.id, 'user1');
    expect(user.name, '');
    expect(user.surname, '');
    expect(user.address, '');
    expect(user.email, '');
    expect(user.role, '');
  });

  test('fromMap uses the provided document id', () {
    final user = AppUser.fromMap(
      {
        'name': 'John',
        'surname': 'Doe',
        'address': 'Main Street 10',
        'email': 'john@example.com',
        'role': 'student',
      },
      'firebase-doc-123',
    );

    expect(user.id, 'firebase-doc-123');
  });
}