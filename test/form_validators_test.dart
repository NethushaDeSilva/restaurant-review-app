import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_review_app/utils/form_validators.dart';

void main() {
  group('validateEmail preserves the auth forms\' validation', () {
    test('missing values keep the required-field message', () {
      for (final String? value in [null, '', '   ']) {
        expect(validateEmail(value), 'Enter your email address');
      }
    });

    test('accepts supported addresses and surrounding whitespace', () {
      for (final String value in [
        'user@example.com',
        'first.last-name@example-domain.lk',
        '  user@example.com  ',
      ]) {
        expect(validateEmail(value), isNull);
      }
    });

    test('keeps the existing restrictions and invalid-address message', () {
      for (final String value in [
        'user',
        'user@example',
        'user@example.c',
        'user name@example.com',
        'user+tag@example.com',
        'user@mail.example.com',
      ]) {
        expect(validateEmail(value), 'Enter a valid email address');
      }
    });
  });
}
