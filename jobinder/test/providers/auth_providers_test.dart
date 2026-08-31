import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/providers/auth_provider.dart';

import '../fakes.dart';

void main() {
  late FakeAuthService authService;
  late AuthProvider provider;

  setUp(() {
    authService = FakeAuthService();
    provider = AuthProvider(authService);
  });

  tearDown(() {
    authService.dispose();
  });

  test('starts without user, appUser, loading or error', () {
    expect(provider.user, isNull);
    expect(provider.appUser, isNull);
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
  });

  test('successful sign in returns true and clears error', () async {
    authService.signInError = null;

    final result = await provider.signInWithEmailAndPassword('test@test.com', 'password');

    expect(result, isTrue);
    expect(provider.errorMessage, isNull);
    expect(provider.isLoading, isFalse);
  });

  test('failed sign in returns false and exposes the error message', () async {
    authService.signInError = 'User not found';

    final result = await provider.signInWithEmailAndPassword('test@test.com', 'password');

    expect(result, isFalse);
    expect(provider.errorMessage, 'User not found');
    expect(provider.isLoading, isFalse);
  });

  test('isLoading is true while authenticating', () async {
    authService.gate = Completer<void>();

    final future = provider.signInWithEmailAndPassword('test@test.com', 'password');
    await Future<void>.delayed(Duration.zero);

    expect(provider.isLoading, isTrue);

    authService.gate!.complete();
    await future;

    expect(provider.isLoading, isFalse);
  });

  test('signOut updates errorMessage if error occurs during sign out', () async {
    authService.signOutError = 'Error signing out';

    await provider.signOut();

    expect(provider.errorMessage, 'Error signing out');
  });

  test('clearError resets the error message to null', () async {
    authService.signInError = 'Error occurred';
    await provider.signInWithEmailAndPassword('test@test.com', 'password');
    expect(provider.errorMessage, 'Error occurred');

    provider.clearError();

    expect(provider.errorMessage, isNull);
  });
}