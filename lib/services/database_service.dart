import 'package:firebase_database/firebase_database.dart';

import '../models/restaurant.dart';
import '../models/review.dart';

/// Realtime collection reads and owner-scoped writes enforced by database rules.
class DatabaseService {
  static final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ---------------------------------------------------------------- READ

  /// Live list of every restaurant, sorted by name.
  static Stream<List<Restaurant>> restaurantsStream() {
    return _db.child('restaurants').onValue.map((DatabaseEvent event) {
      final Object? data = event.snapshot.value;
      if (data == null) {
        return <Restaurant>[];
      }

      final Map<dynamic, dynamic> records = data as Map<dynamic, dynamic>;
      final List<Restaurant> restaurants = [];
      records.forEach((key, value) {
        restaurants.add(
          Restaurant.fromMap(key.toString(), value as Map<dynamic, dynamic>),
        );
      });

      restaurants.sort((a, b) => a.name.compareTo(b.name));
      return restaurants;
    });
  }

  /// Live list of every review in the database.
  static Stream<List<Review>> reviewsStream() {
    return _db.child('reviews').onValue.map((DatabaseEvent event) {
      final Object? data = event.snapshot.value;
      if (data == null) {
        return <Review>[];
      }

      final Map<dynamic, dynamic> records = data as Map<dynamic, dynamic>;
      final List<Review> reviews = [];
      records.forEach((key, value) {
        reviews.add(
          Review.fromMap(key.toString(), value as Map<dynamic, dynamic>),
        );
      });

      return reviews;
    });
  }

  // -------------------------------------------------- CREATE / UPDATE / DELETE
  //
  // Reviews and restaurants both go through the same three operations. In
  // each case push() generates a unique key, so two people writing at the
  // same moment cannot overwrite each other.

  static Future<void> addReview(Review review) async {
    await _db.child('reviews').push().set(review.toMap());
  }

  static Future<void> updateReview(Review review) async {
    await _db.child('reviews').child(review.id).update(review.toMap());
  }

  static Future<void> deleteReview(String reviewId) async {
    await _db.child('reviews').child(reviewId).remove();
  }

  static Future<void> addRestaurant(Restaurant restaurant) async {
    await _db.child('restaurants').push().set(restaurant.toMap());
  }

  static Future<void> updateRestaurant(Restaurant restaurant) async {
    await _db
        .child('restaurants')
        .child(restaurant.id)
        .update(restaurant.toMap());
  }

  /// Deletes the listing but retains reviews; only their authors may delete them.
  static Future<void> deleteRestaurant(String restaurantId) async {
    await _db.child('restaurants').child(restaurantId).remove();
  }
}
