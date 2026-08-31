import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/view/admin_page.dart';

import '../fakes.dart';

class TestAuthProvider extends AuthProvider {
  final StreamController<List<AppUser>> _usersController = StreamController<List<AppUser>>.broadcast();
  bool _mockIsLoading = false;
  bool signOutCalled = false;

  TestAuthProvider(super.authService);

  void setUsers(List<AppUser> usersList) {
    _usersController.add(usersList);
  }

  void setError(Object error) {
    _usersController.addError(error);
  }

  void setLoading(bool loading) {
    _mockIsLoading = loading;
    notifyListeners();
  }

  @override
  Stream<List<AppUser>> get users => _usersController.stream;

  @override
  bool get isLoading => _mockIsLoading;

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  void disposeStream() {
    _usersController.close();
  }
}

void main() {
  late FakeAuthService authService;
  late TestAuthProvider authProvider;

  setUp(() {
    authService = FakeAuthService();
    authProvider = TestAuthProvider(authService);
  });

  tearDown(() {
    authProvider.disposeStream();
    authService.dispose();
  });

  Widget createAdminPage() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: const MaterialApp(
        home: AdminPage(),
      ),
    );
  }

  testWidgets('Display the loader when isLoading is true', (tester) async {
    authProvider.setLoading(true);

    await tester.pumpWidget(createAdminPage());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Display "No users found." when the user list is empty', (tester) async {
    await tester.pumpWidget(createAdminPage());

    authProvider.setUsers([]);
    await tester.pumpAndSettle();

    expect(find.text('No users found.'), findsOneWidget);
  });

  testWidgets('show list of users with icons and infos', (tester) async {
    final mockUsers = [
      AppUser(
        id: 'usr_1',
        name: 'John',
        surname: 'Doe',
        email: 'john@example.com',
        role: 'student',
        address: 'Lausanne',
      ),
      AppUser(
        id: 'usr_2',
        name: 'Jane',
        surname: 'Smith',
        email: 'jane@company.com',
        role: 'employer',
        address: 'Sion',
      ),
    ];

    await tester.pumpWidget(createAdminPage());

    authProvider.setUsers(mockUsers);
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('john@example.com | student'), findsOneWidget);

    expect(find.text('Jane Smith'), findsOneWidget);
    expect(find.text('jane@company.com | employer'), findsOneWidget);

    expect(find.byIcon(Icons.school), findsOneWidget);
    expect(find.byIcon(Icons.business), findsOneWidget);
  });

}