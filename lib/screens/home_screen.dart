import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../services/database_service.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_detail_screen.dart';

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

          // Highest rated first, then take the leading few.
          final List<Restaurant> sorted = List.from(all);
          sorted.sort((a, b) => b.rating.compareTo(a.rating));
          final List<Restaurant> featured = sorted.take(4).toList();

          // On a wide screen the cards would stretch to an awkward width, so
          // the column is capped and centred instead.
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
                      onTap: () => _openDetail(context, restaurant),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
