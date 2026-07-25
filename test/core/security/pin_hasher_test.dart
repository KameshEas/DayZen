import 'package:flutter_test/flutter_test.dart';
import 'package:dayzen/core/security/pin_hasher.dart';

void main() {
  group('PinHasher', () {
    test('same pin + same salt produces the same hash (deterministic)', () {
      final salt = PinHasher.generateSalt();
      final h1 = PinHasher.hash('1234', salt);
      final h2 = PinHasher.hash('1234', salt);
      expect(h1, equals(h2));
    });

    test('different pins produce different hashes for the same salt', () {
      final salt = PinHasher.generateSalt();
      final h1 = PinHasher.hash('1234', salt);
      final h2 = PinHasher.hash('4321', salt);
      expect(h1, isNot(equals(h2)));
    });

    test('same pin with different salts produces different hashes', () {
      final salt1 = PinHasher.generateSalt();
      final salt2 = PinHasher.generateSalt();
      expect(salt1, isNot(equals(salt2)));
      final h1 = PinHasher.hash('1234', salt1);
      final h2 = PinHasher.hash('1234', salt2);
      expect(h1, isNot(equals(h2)));
    });

    test('generateSalt produces unique values across calls', () {
      final salts = List.generate(20, (_) => PinHasher.generateSalt());
      expect(salts.toSet().length, 20);
    });

    test('hash output is deterministic length (base64 of 32 bytes)', () {
      final salt = PinHasher.generateSalt();
      final hash = PinHasher.hash('0000', salt);
      // 32 bytes -> 44 base64 chars including padding
      expect(hash.length, 44);
    });

    test('constantTimeEquals returns true for identical strings', () {
      expect(PinHasher.constantTimeEquals('abc123', 'abc123'), isTrue);
    });

    test('constantTimeEquals returns false for different strings', () {
      expect(PinHasher.constantTimeEquals('abc123', 'abc124'), isFalse);
    });

    test('constantTimeEquals returns false for different-length strings', () {
      expect(PinHasher.constantTimeEquals('abc', 'abcd'), isFalse);
    });
  });
}
