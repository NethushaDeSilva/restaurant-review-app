// Unit tests for the two model classes.
//
// The app itself cannot be pumped in a test without a running Firebase
// connection, so these cover the part that has real logic in it: turning a
// Firebase record into a Dart object and back again. The rest of the testing
// evidence for this assignment is the manual test table in the documentation.

import 'package:flutter_test/flutter_test.dart';

import 'package:restaurant_review_app/models/restaurant.dart';
import 'package:restaurant_review_app/models/review.dart';

void main() {
  group('Restaurant.fromMap', () {
    test('reads every field from a complete record', () {
      final Restaurant restaurant = Restaurant.fromMap('r1', {
        'name': 'Ministry of Crab',
        'cuisine': 'Seafood',
        'area': 'Colombo 01',
        'rating': 4.8,
        'priceRange': 'Rs 6,000 - 12,000',
        'imageUrl': 'https://example.com/crab.jpg',
        'description': 'Lagoon crab by size.',
        'latitude': 6.9344,
        'longitude': 79.8428,
      });

      expect(restaurant.id, 'r1');
      expect(restaurant.name, 'Ministry of Crab');
      expect(restaurant.rating, 4.8);
      expect(restaurant.latitude, 6.9344);
    });

    test('falls back safely when fields are missing', () {
      // A record saved without a rating should not crash the whole list.
      final Restaurant restaurant = Restaurant.fromMap('r2', {
        'name': 'Nihonbashi',
      });

      expect(restaurant.name, 'Nihonbashi');
      expect(restaurant.rating, 0);
      expect(restaurant.cuisine, '');
    });

    test('handles a rating stored as a whole number', () {
      // Firebase returns 5 rather than 5.0 when the decimal is zero.
      final Restaurant restaurant = Restaurant.fromMap('r3', {
        'name': 'Green Cabin',
        'rating': 5,
      });

      expect(restaurant.rating, 5.0);
    });
  });

  group('Restaurant ownership', () {
    Restaurant build(String ownerId) {
      return Restaurant.fromMap('r1', {
        'name': 'Amara Kitchen',
        'ownerId': ownerId,
      });
    }

    test('an imported restaurant has no owner', () {
      // The eight restaurants loaded by the initial import carry no ownerId,
      // so nobody owns them and anybody may review them.
      final Restaurant restaurant = build('');

      expect(restaurant.isUserAdded, false);
      expect(restaurant.isOwnedBy('user-123'), false);
    });

    test('recognises its owner', () {
      final Restaurant restaurant = build('user-123');

      expect(restaurant.isUserAdded, true);
      expect(restaurant.isOwnedBy('user-123'), true);
    });

    test('does not treat a different user as the owner', () {
      final Restaurant restaurant = build('user-123');

      expect(restaurant.isOwnedBy('user-999'), false);
    });

    test('an empty user id never matches an unowned restaurant', () {
      // Guards the case where a signed-out uid ('') is compared against an
      // imported restaurant whose ownerId is also '', which would otherwise
      // wrongly report ownership.
      final Restaurant restaurant = build('');

      expect(restaurant.isOwnedBy(''), false);
    });
  });

  group('Review', () {
    test('survives a round trip through toMap and fromMap', () {
      final Review original = Review(
        id: 'v1',
        restaurantId: 'r1',
        userId: 'user-123',
        authorName: 'Nethusha De Silva',
        rating: 4.5,
        comment: 'Booked the Half Kilo crab. Worth it once.',
        visitType: 'Dinner',
        visitDate: '12 Aug 2026',
      );

      final Review restored = Review.fromMap('v1', original.toMap());

      expect(restored.id, original.id);
      expect(restored.restaurantId, original.restaurantId);
      expect(restored.userId, original.userId);
      expect(restored.authorName, original.authorName);
      expect(restored.rating, original.rating);
      expect(restored.comment, original.comment);
      expect(restored.visitType, original.visitType);
      expect(restored.visitDate, original.visitDate);
    });

    test('uses a placeholder when the author name is missing', () {
      final Review review = Review.fromMap('v2', {
        'restaurantId': 'r1',
        'rating': 3,
      });

      expect(review.authorName, 'Unknown');
    });
  });
}
