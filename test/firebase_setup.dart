import 'package:firebase_core/firebase_core.dart';

/// Initialize Firebase for tests if available.
/// In test environments, Firebase may not be available on all platforms.
/// This helper allows tests to run gracefully without Firebase initialization.
Future<void> setupFirebaseForTests() async {
  try {
    // Attempt to initialize Firebase with default options
    // This may fail in test environments which is acceptable
    if (!Firebase.apps.isEmpty) {
      return; // Already initialized
    }

    // Try to initialize - this will likely fail in unit tests
    // but the try-catch ensures we don't block test execution
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase initialization failed - this is expected in many test environments
    // Tests can still run without Firebase
  }
}
