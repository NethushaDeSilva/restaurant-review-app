/// A single restaurant record.
///
/// Restaurants are created by users from their profile. [ownerId] holds the
/// Firebase Auth uid of whoever added it, which does two jobs: only the
/// owner may edit or delete it, and the owner is blocked from reviewing it.
///
/// The eight restaurants loaded by the initial import have an empty
/// ownerId, so nobody owns them and anybody may review them.
class Restaurant {
  final String id;
  final String ownerId;
  final String name;
  final String cuisine;
  final String area;
  final double rating;
  final String priceRange;
  final String imageUrl;
  final String description;
  final String popularDishes;
  final double latitude;
  final double longitude;

  Restaurant({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.cuisine,
    required this.area,
    required this.rating,
    required this.priceRange,
    required this.imageUrl,
    required this.description,
    required this.popularDishes,
    required this.latitude,
    required this.longitude,
  });

  /// True when this restaurant was added by a user rather than loaded by the
  /// initial import.
  bool get isUserAdded => ownerId.isNotEmpty;

  /// True if the given user added this restaurant.
  bool isOwnedBy(String userId) => ownerId.isNotEmpty && ownerId == userId;

  /// Builds a Restaurant from one Firebase record.
  ///
  /// Firebase returns a Map with dynamic values, so each field is converted
  /// to the type we expect. The ?? fallbacks mean a missing or misspelled
  /// field gives an empty value instead of crashing the whole list.
  factory Restaurant.fromMap(String id, Map<dynamic, dynamic> map) {
    return Restaurant(
      id: id,
      ownerId: map['ownerId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      cuisine: map['cuisine']?.toString() ?? '',
      area: map['area']?.toString() ?? '',
      rating: double.tryParse(map['rating']?.toString() ?? '') ?? 0,
      priceRange: map['priceRange']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      popularDishes: map['popularDishes']?.toString() ?? '',
      latitude: double.tryParse(map['latitude']?.toString() ?? '') ?? 0,
      longitude: double.tryParse(map['longitude']?.toString() ?? '') ?? 0,
    );
  }

  /// Converts back to a Map so it can be written to Firebase.
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'cuisine': cuisine,
      'area': area,
      'rating': rating,
      'priceRange': priceRange,
      'imageUrl': imageUrl,
      'description': description,
      'popularDishes': popularDishes,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
