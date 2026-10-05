import '../models/review.dart';

Map<String, ({double average, int count})> ratingsByRestaurant(
  List<Review> reviews,
) {
  final Map<String, List<double>> grouped = {};
  for (final Review review in reviews) {
    grouped.putIfAbsent(review.restaurantId, () => []).add(review.rating);
  }

  final Map<String, ({double average, int count})> result = {};
  grouped.forEach((restaurantId, ratings) {
    final double total = ratings.fold<double>(0, (sum, rating) => sum + rating);
    final double rounded = double.parse(
      (total / ratings.length).toStringAsFixed(1),
    );
    result[restaurantId] = (average: rounded, count: ratings.length);
  });
  return result;
}
