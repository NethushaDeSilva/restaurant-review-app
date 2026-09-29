import 'package:flutter/material.dart';

import '../../models/restaurant.dart';
import '../../models/review.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/ratings.dart';
import '../../shared_widgets/restaurant_image.dart';
import '../my_reviews/add_review_screen.dart';

/// Displays a restaurant snapshot with live reviews.
class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  void _writeReview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewScreen(restaurant: restaurant),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colours.primaryContainer,
                  child: Text(
                    review.authorName.isEmpty
                        ? '?'
                        : review.authorName.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: colours.onPrimaryContainer),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    review.authorName,
                    style: text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.star, size: 16, color: colours.primary),
                const SizedBox(width: 2),
                Text(review.rating.toStringAsFixed(1), style: text.labelLarge),
              ],
            ),
            const SizedBox(height: 10),
            Text(review.comment, style: text.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(review.visitType),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelStyle: text.labelSmall,
                ),
                const SizedBox(width: 8),
                Text(
                  review.visitDate,
                  style: text.labelSmall?.copyWith(
                    color: colours.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// [mine] contains only reviews for this restaurant.
  Widget _buildReviewSection(BuildContext context, List<Review> mine) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    if (mine.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No reviews yet. Be the first to write one.',
            style: text.bodyMedium?.copyWith(color: colours.onSurfaceVariant),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final Review review in mine) _buildReviewCard(context, review),
      ],
    );
  }

  /// [stats] is null when this restaurant has no reviews.
  Widget _buildDetails(
    BuildContext context,
    bool isMyRestaurant,
    ({double average, int count})? stats,
    List<Review> mine,
  ) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(restaurant.name, style: text.headlineSmall),
        const SizedBox(height: 6),

        Row(
          children: [
            if (stats != null) ...[
              Icon(Icons.star, size: 20, color: colours.primary),
              const SizedBox(width: 4),
              Text(stats.average.toStringAsFixed(1), style: text.titleMedium),
            ] else
              Text(
                'No ratings yet',
                style: text.bodyMedium?.copyWith(
                  color: colours.onSurfaceVariant,
                ),
              ),
            const SizedBox(width: 12),
            Text('·', style: text.titleMedium),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                restaurant.cuisine,
                style: text.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (stats != null) ...[
          const SizedBox(height: 2),
          Text(
            'Based on ${stats.count} review${stats.count == 1 ? '' : 's'}',
            style: text.bodySmall?.copyWith(color: colours.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 14),

        if (isMyRestaurant) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colours.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 20,
                  color: colours.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is your restaurant. Owners cannot review their own '
                    'listings.',
                    style: text.bodySmall?.copyWith(
                      color: colours.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 18,
              color: colours.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(restaurant.area, style: text.bodyMedium)),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Icon(
              Icons.payments_outlined,
              size: 18,
              color: colours.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(restaurant.priceRange, style: text.bodyMedium),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Text('About', style: text.titleMedium),
        const SizedBox(height: 8),
        Text(restaurant.description, style: text.bodyMedium),

        if (restaurant.popularDishes.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Popular dishes', style: text.titleMedium),
          const SizedBox(height: 8),
          Text(restaurant.popularDishes, style: text.bodyMedium),
        ],

        const SizedBox(height: 24),
        Text('Reviews', style: text.titleMedium),
        const SizedBox(height: 12),
        _buildReviewSection(context, mine),
        const SizedBox(height: 80), // clearance for the floating button
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hide the review action for the listing owner.
    final String myId = AuthService.currentUser?.uid ?? '';
    final bool isMyRestaurant = restaurant.isOwnedBy(myId);

    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),
      floatingActionButton: isMyRestaurant
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _writeReview(context),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Write a review'),
            ),

      body: StreamBuilder<List<Review>>(
        stream: DatabaseService.reviewsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Could not load reviews.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          }

          final List<Review> mine = (snapshot.data ?? <Review>[])
              .where((review) => review.restaurantId == restaurant.id)
              .toList();
          final ({double average, int count})? stats =
              ratingsByRestaurant(mine)[restaurant.id];

          return OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.landscape) {
                // Keep the photo beside the text on short landscape screens.
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox.expand(
                        child: RestaurantImage(
                          imageUrl: restaurant.imageUrl,
                          heroTag: restaurant.id,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _buildDetails(
                          context,
                          isMyRestaurant,
                          stats,
                          mine,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RestaurantImage(
                      imageUrl: restaurant.imageUrl,
                      height: 220,
                      heroTag: restaurant.id,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildDetails(
                        context,
                        isMyRestaurant,
                        stats,
                        mine,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
