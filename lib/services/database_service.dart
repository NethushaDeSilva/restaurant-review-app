import 'package:firebase_database/firebase_database.dart';

import '../models/restaurant.dart';
import '../models/review.dart';

/// Every Firebase Realtime Database call in the app.
///
/// Reads return Streams rather than Futures. A Stream keeps delivering new
/// values whenever the data changes, so a list built from one updates by
/// itself when a record is added on another device.
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

  /// Removes a restaurant listing.
  ///
  /// Deliberately does not delete the reviews customers wrote about it. If
  /// an owner could remove reviews, they could delete the bad ones, and the
  /// security rules keep deletion with the review's author for exactly that
  /// reason. Reviews left without a restaurant simply stop being displayed.
  static Future<void> deleteRestaurant(String restaurantId) async {
    await _db.child('restaurants').child(restaurantId).remove();
  }
}
