import 'package:flutter_test/flutter_test.dart';

import 'package:restaurant_review_app/models/restaurant.dart';
import 'package:restaurant_review_app/models/review.dart';
import 'package:restaurant_review_app/utils/ratings.dart';

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
      final Restaurant restaurant = Restaurant.fromMap('r2', {
        'name': 'Nihonbashi',
      });

      expect(restaurant.name, 'Nihonbashi');
      expect(restaurant.rating, 0);
      expect(restaurant.cuisine, '');
    });

    test('handles a rating stored as a whole number', () {
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

  group('ratingsByRestaurant', () {
    Review review(String restaurantId, double rating) {
      return Review(
        id: '',
        restaurantId: restaurantId,
        userId: 'user-1',
        authorName: 'Reviewer',
        rating: rating,
        comment: 'Placeholder comment for the test review.',
        visitType: 'Dinner',
        visitDate: '1 Jan 2026',
      );
    }

    test('an empty review list produces an empty map', () {
      expect(ratingsByRestaurant([]), isEmpty);
    });

    test('a single review sets the average to its own rating', () {
      final Map<String, ({double average, int count})> ratings =
          ratingsByRestaurant([review('r1', 4.0)]);

      expect(ratings['r1']?.average, 4.0);
      expect(ratings['r1']?.count, 1);
    });

    test('groups reviews by restaurant and averages each separately', () {
      final Map<String, ({double average, int count})> ratings =
          ratingsByRestaurant([
            review('r1', 5.0),
            review('r1', 3.0),
            review('r2', 2.0),
          ]);

      expect(ratings['r1']?.average, 4.0);
      expect(ratings['r1']?.count, 2);
      expect(ratings['r2']?.average, 2.0);
      expect(ratings['r2']?.count, 1);
    });

    test('a restaurant with no reviews has no entry in the map', () {
      final Map<String, ({double average, int count})> ratings =
          ratingsByRestaurant([review('r1', 4.0)]);

      expect(ratings.containsKey('r2'), false);
    });

    test('rounds the average to one decimal place', () {
      final Map<String, ({double average, int count})> ratings =
          ratingsByRestaurant([
            review('r1', 4.0),
            review('r1', 4.0),
            review('r1', 5.0),
          ]);

      expect(ratings['r1']?.average, 4.3);
    });
  });
}
