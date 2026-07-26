import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../lib/features/auth/auth_controller.dart';

/// A fake [FirebaseAuth] that throws configurable exceptions.
/// Uses [Fake] to avoid implementing every method on [FirebaseAuth].
class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  String throwCode = 'user-not-found';

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw FirebaseAuthException(code: throwCode);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw FirebaseAuthException(code: throwCode);
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) async {
    throw FirebaseAuthException(code: throwCode);
  }
}

void main() {
  late _FakeFirebaseAuth fakeAuth;
  late AuthController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fakeAuth = _FakeFirebaseAuth();
    controller = AuthController(auth: fakeAuth);
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

  group('AuthController - error mapping', () {
    test('user-not-found maps to friendly message', () async {
      fakeAuth.throwCode = 'user-not-found';
      final result = await controller.signIn(
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Incorrect email or password.');
    });

    test('email-already-in-use maps to friendly message', () async {
      fakeAuth.throwCode = 'email-already-in-use';
      final result = await controller.signUp(
        fullName: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'An account with this email already exists.');
    });

    test('invalid-email maps to friendly message', () async {
      fakeAuth.throwCode = 'invalid-email';
      final result = await controller.signIn(
        email: 'not-an-email',
        password: 'password123',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Please enter a valid email address.');
    });

    test('weak-password maps to friendly message', () async {
      fakeAuth.throwCode = 'weak-password';
      final result = await controller.signUp(
        fullName: 'Test User',
        email: 'test@example.com',
        password: 'short',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Password must be at least 6 characters.');
    });

    test('network-request-failed maps to friendly message', () async {
      fakeAuth.throwCode = 'network-request-failed';
      final result = await controller.signIn(
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'No internet connection.');
    });

    test('too-many-requests maps to friendly message', () async {
      fakeAuth.throwCode = 'too-many-requests';
      final result = await controller.signIn(
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Too many attempts. Please try again later.');
    });

    test('unknown error code maps to default message', () async {
      fakeAuth.throwCode = 'unknown-error';
      final result = await controller.signIn(
        email: 'test@example.com',
        password: 'password123',
        onSuccess: () {},
      );

      expect(result, false);
      expect(controller.error, 'Authentication failed. Please try again.');
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