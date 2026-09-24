import '../models/review.dart';

/// Groups reviews by restaurant and averages their ratings.
///
/// A restaurant with no reviews gets no entry in the returned map. Reporting
/// "0.0" for an unreviewed restaurant would look like a real, poor score
/// rather than the absence of one, so callers should treat a missing key as
/// "not yet rated" rather than defaulting the average to zero themselves.
Map<String, ({double average, int count})> ratingsByRestaurant(
  List<Review> reviews,
) {
  final Map<String, List<double>> grouped = {};
  for (final Review review in reviews) {
    grouped.putIfAbsent(review.restaurantId, () => []).add(review.rating);
  }

  final Map<String, ({double average, int count})> result = {};
  grouped.forEach((restaurantId, ratings) {
    double total = 0;
    for (final double rating in ratings) {
      total = total + rating;
    }
    final double rounded = double.parse(
      (total / ratings.length).toStringAsFixed(1),
    );
    result[restaurantId] = (average: rounded, count: ratings.length);
  });
  return result;
}
