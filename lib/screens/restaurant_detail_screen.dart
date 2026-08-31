import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/restaurant_image.dart';
import 'add_review_screen.dart';

/// The "detail" half of the master/detail pair.
///
/// The restaurant arrives through the constructor, handed straight in by
/// Navigator.push. The reviews underneath are read live from Firebase.
///
/// Two layouts:
///   portrait  - photo across the top, details scrolling underneath
///   landscape - photo down the left, details scrolling on the right
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

  /// The reviews section, rebuilt whenever the reviews change in Firebase.
  Widget _buildReviewSection(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return StreamBuilder<List<Review>>(
      stream: DatabaseService.reviewsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Card(
            color: colours.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Could not load reviews.',
                style: text.bodyMedium?.copyWith(
                  color: colours.onErrorContainer,
                ),
              ),
            ),
          );
        }

        // Keep only the reviews belonging to this restaurant.
        final List<Review> all = snapshot.data ?? [];
        final List<Review> mine = [];
        for (final Review review in all) {
          if (review.restaurantId == restaurant.id) {
            mine.add(review);
          }
        }

        if (mine.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No reviews yet. Be the first to write one.',
                style: text.bodyMedium?.copyWith(
                  color: colours.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final Review review in mine) _buildReviewCard(context, review),
          ],
        );
      },
    );
  }

  /// The text half of the screen. Identical in both orientations, which is
  /// why it lives in its own method rather than being written out twice.
  Widget _buildDetails(BuildContext context, bool isMyRestaurant) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(restaurant.name, style: text.headlineSmall),
        const SizedBox(height: 6),

        Row(
          children: [
            // A newly added listing has no rating until customers review it.
            if (restaurant.rating > 0) ...[
              Icon(Icons.star, size: 20, color: colours.primary),
              const SizedBox(width: 4),
              Text(
                restaurant.rating.toStringAsFixed(1),
                style: text.titleMedium,
              ),
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
        const SizedBox(height: 14),

        // Shown only to the owner, so it is obvious why there is no button
        // to write a review on this page.
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

        // Only user-added listings carry this, so the section is hidden
        // when it is empty rather than showing an empty heading.
        if (restaurant.popularDishes.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Popular dishes', style: text.titleMedium),
          const SizedBox(height: 8),
          Text(restaurant.popularDishes, style: text.bodyMedium),
        ],

        const SizedBox(height: 24),
        Text('Reviews', style: text.titleMedium),
        const SizedBox(height: 12),
        _buildReviewSection(context),
        const SizedBox(height: 80), // clearance for the floating button
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // An owner may not review their own restaurant, so the button that
    // starts a review is not offered to them at all. The database rules
    // reject it as well, in case anyone tries another way in.
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
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            // Sideways: the photo takes the left and the text scrolls
            // independently on the right. Without this the photo would eat
            // most of a short landscape screen.
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
                    child: _buildDetails(context, isMyRestaurant),
                  ),
                ),
              ],
            );
          }

          // Upright: the familiar photo-on-top layout.
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
                  child: _buildDetails(context, isMyRestaurant),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
