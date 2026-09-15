import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dayzen/features/auth/auth_controller.dart';
import 'package:dayzen/core/services/jwt_auth_service.dart';

/// A fake [JwtAuthService] whose sign-in/sign-up/reset results (or thrown
/// error) are configured per test, so [AuthController]'s handling of each
/// path can be exercised without a real backend.
class _FakeJwtAuthService extends JwtAuthService {
  bool signInResult = true;
  bool signUpResult = true;
  Object? throwOnNextCall;

  @override
  Future<bool> signIn({
    required String email,
    required String password,
    required String apiBaseUrl,
  }) async {
    if (throwOnNextCall != null) throw throwOnNextCall!;
    return signInResult;
  }

  @override
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String apiBaseUrl,
  }) async {
    if (throwOnNextCall != null) throw throwOnNextCall!;
    return signUpResult;
  }

  @override
  Future<void> requestPasswordReset({
    required String email,
    required String apiBaseUrl,
  }) async {
    if (throwOnNextCall != null) throw throwOnNextCall!;
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  late _FakeJwtAuthService fakeAuthService;
  late AuthController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fakeAuthService = _FakeJwtAuthService();
    controller = AuthController(authService: fakeAuthService);
  });

  tearDown(() {
    controller.dispose();
  });

  group('AuthController - validation', () {
    test('initial state has no error and is not loading', () {
      expect(controller.isLoading, false);
      expect(controller.error, null);
    });

    test('clearError clears the error state', () {
      controller.signIn(
        email: '',
        password: '',
        onSuccess: () {},
      );
      expect(controller.error, isNotNull);

      controller.clearError();
      expect(controller.error, null);
    });

    test('signIn with empty email returns error', () async {
      final result = await controller.signIn(
        email: '',
        password: 'password123',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Please fill in all fields.');
    });

    test('signIn with empty password returns error', () async {
      final result = await controller.signIn(
        email: 'test@example.com',
        password: '',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Please fill in all fields.');
    });

    test('signIn with both empty returns error', () async {
      final result = await controller.signIn(
        email: '',
        password: '',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Please fill in all fields.');
    });

    test('signUp with empty name returns error', () async {
      final result = await controller.signUp(
        fullName: '',
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Please fill in all fields.');
    });

    test('signUp with empty email returns error', () async {
      final result = await controller.signUp(
        fullName: 'Test User',
        email: '',
        password: 'password123',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Please fill in all fields.');
    });

    test('signUp with short password returns error', () async {
      final result = await controller.signUp(
        fullName: 'Test User',
        email: 'test@example.com',
        password: '12345',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Password must be at least 6 characters.');
    });

    test('signUp with empty password returns error', () async {
      final result = await controller.signUp(
        fullName: 'Test User',
        email: 'test@example.com',
        password: '',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Please fill in all fields.');
    });

    test('sendPasswordReset with empty email returns error', () async {
      final result = await controller.sendPasswordReset(email: '');

      expect(result, false);
      expect(controller.error, 'Please enter your email address.');
    });
  });

  // AuthController talks to a REST backend now (not Firebase), so it no
  // longer maps per-error-code messages -- every backend failure collapses
  // to one of two generic messages depending on whether the auth service
  // returned false (a handled failure) or threw (an unexpected one).
  group('AuthController - backend failure handling', () {
    test('signIn returning false shows the incorrect-credentials message', () async {
      fakeAuthService.signInResult = false;
      final result = await controller.signIn(
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Incorrect email or password.');
    });

    test('signIn throwing shows the generic unexpected-error message', () async {
      fakeAuthService.throwOnNextCall = Exception('network down');
      final result = await controller.signIn(
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'An unexpected error occurred. Please try again.');
    });

    test('signUp returning false shows the account-creation-failed message', () async {
      fakeAuthService.signUpResult = false;
      final result = await controller.signUp(
        fullName: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Failed to create account. Please try again.');
    });

    test('signUp throwing shows the generic unexpected-error message', () async {
      fakeAuthService.throwOnNextCall = Exception('network down');
      final result = await controller.signUp(
        fullName: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'An unexpected error occurred. Please try again.');
    });

    test('sendPasswordReset throwing shows the reset-failed message', () async {
      fakeAuthService.throwOnNextCall = Exception('network down');
      final result = await controller.sendPasswordReset(email: 'test@example.com');

      expect(result, false);
      expect(controller.error, 'Failed to send reset email. Please try again.');
    });
  });

  group('AuthController - success path', () {
    test('signIn success clears loading and calls onSuccess', () async {
      var successCalled = false;
      final result = await controller.signIn(
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () => successCalled = true,
      );

      expect(result, true);
      expect(successCalled, true);
      expect(controller.isLoading, false);
      expect(controller.error, null);
    });

    test('signUp success clears loading and calls onSuccess', () async {
      var successCalled = false;
      final result = await controller.signUp(
        fullName: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () => successCalled = true,
      );

      expect(result, true);
      expect(successCalled, true);
      expect(controller.isLoading, false);
      expect(controller.error, null);
    });

    test('sendPasswordReset success clears loading', () async {
      final result = await controller.sendPasswordReset(email: 'test@example.com');

      expect(result, true);
      expect(controller.isLoading, false);
    });
  });

  group('AuthController - loading state', () {
    test('signIn resets loading to false after completion', () async {
      await controller.signIn(
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () {},
      );

      expect(controller.isLoading, false);
    });

    test('signUp resets loading to false after completion', () async {
      await controller.signUp(
        fullName: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () {},
      );

      expect(controller.isLoading, false);
    });

    test('sendPasswordReset resets loading to false', () async {
      await controller.sendPasswordReset(email: 'test@example.com');

      expect(controller.isLoading, false);
    });
  });
}
