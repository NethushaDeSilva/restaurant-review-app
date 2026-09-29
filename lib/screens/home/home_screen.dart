import 'package:flutter/material.dart';

import '../../models/restaurant.dart';
import '../../models/review.dart';
import '../../services/database_service.dart';
import '../../utils/ratings.dart';
import '../../shared_widgets/restaurant_card.dart';
import '../restaurants/restaurant_detail_screen.dart';

/// Landing tab: the highest-rated places, so the app opens on something
/// useful rather than an empty dashboard.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openDetail(BuildContext context, Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Colombo Eats')),
      body: StreamBuilder<List<Restaurant>>(
        stream: DatabaseService.restaurantsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 48,
                      color: colours.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text('Could not load restaurants', style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Check your internet connection and try again.',
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(
                        color: colours.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final List<Restaurant> all = snapshot.data ?? [];
          if (all.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No restaurants in the database yet.',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: colours.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }

          // Display ratings calculated from reviews, not restaurant.rating.
          return StreamBuilder<List<Review>>(
            stream: DatabaseService.reviewsStream(),
            builder: (context, reviewSnapshot) {
              if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (reviewSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Could not load ratings.',
                      style: text.bodyMedium?.copyWith(
                        color: colours.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              final Map<String, ({double average, int count})> ratings =
                  ratingsByRestaurant(reviewSnapshot.data ?? []);

              // Unreviewed restaurants sort after rated restaurants.
              final List<Restaurant> sorted = List.from(all);
              sorted.sort((a, b) {
                final ({double average, int count})? ratingA = ratings[a.id];
                final ({double average, int count})? ratingB = ratings[b.id];
                if (ratingA == null && ratingB == null) {
                  return 0;
                }
                if (ratingA == null) {
                  return 1;
                }
                if (ratingB == null) {
                  return -1;
                }
                return ratingB.average.compareTo(ratingA.average);
              });
              final List<Restaurant> featured = sorted.take(4).toList();

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    children: [
                      Text('Top rated this month', style: text.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        'The highest-scoring places across Colombo right now',
                        style: text.bodyMedium?.copyWith(
                          color: colours.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final Restaurant restaurant in featured)
                        RestaurantCard(
                          restaurant: restaurant,
                          reviewCount: ratings[restaurant.id]?.count ?? 0,
                          averageRating: ratings[restaurant.id]?.average,
                          onTap: () => _openDetail(context, restaurant),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
