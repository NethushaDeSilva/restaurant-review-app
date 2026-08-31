/// A single review written by a user about one restaurant.
///
/// [userId] is the Firebase Auth uid of whoever wrote it. The database
/// security rules use it to make sure a user can only edit or delete
/// their own reviews.
class Review {
  final String id;
  final String restaurantId;
  final String userId;
  final String authorName;
  final double rating;
  final String comment;
  final String visitType;
  final String visitDate;

  Review({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.visitType,
    required this.visitDate,
  });

  factory Review.fromMap(String id, Map<dynamic, dynamic> map) {
    return Review(
      id: id,
      restaurantId: map['restaurantId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      authorName: map['authorName']?.toString() ?? 'Unknown',
      rating: double.tryParse(map['rating']?.toString() ?? '') ?? 0,
      comment: map['comment']?.toString() ?? '',
      visitType: map['visitType']?.toString() ?? '',
      visitDate: map['visitDate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'restaurantId': restaurantId,
      'userId': userId,
      'authorName': authorName,
      'rating': rating,
      'comment': comment,
      'visitType': visitType,
      'visitDate': visitDate,
    };
  }
}
