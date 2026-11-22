/// The one password rule for every flow that sets a password (sign-up and
/// password reset). Must match the server's MIN_PASSWORD_LENGTH in
/// aspired2d-services services/dayzen/app/core/password_policy.py.
///
/// Signing in is never checked against this: accounts created when the
/// minimum was 6 keep working until their owner changes the password.
const int minPasswordLength = 8;

/// Error message for a password that breaks the rule, or null if it's fine.
/// [subject] is how the message names the field ("Password", "New password").
String? passwordPolicyError(String password, {String subject = 'Password'}) {
  if (password.length < minPasswordLength) {
    return '$subject must be at least $minPasswordLength characters.';
  }
  if (password.trim().isEmpty) {
    return "$subject can't be only spaces.";
  }
  return null;
}
