import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/restaurant_image.dart';
import 'add_restaurant_screen.dart';
import 'restaurant_detail_screen.dart';

/// The restaurants the signed-in user has added.
///
/// A user may add as many as they like, so a small chain or a place with
/// several branches can list each one separately.
class MyRestaurantsScreen extends StatelessWidget {
  const MyRestaurantsScreen({super.key});

  void _add(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRestaurantScreen()),
    );
  }

  void _edit(BuildContext context, Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddRestaurantScreen(existingRestaurant: restaurant),
      ),
    );
  }

  void _view(BuildContext context, Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Restaurant restaurant,
  ) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ${restaurant.name}?'),
          content: const Text(
            'The listing and every review customers have written about it '
            'will be removed. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await DatabaseService.deleteRestaurant(restaurant.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Restaurant deleted')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;
    final String myId = AuthService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('My Restaurants')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add),
        label: const Text('Add restaurant'),
      ),
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
                child: Text(
                  'Could not load your restaurants.',
                  style: text.bodyMedium,
                ),
              ),
            );
          }

          // Only the listings this user owns.
          final List<Restaurant> all = snapshot.data ?? [];
          final List<Restaurant> mine = [];
          for (final Restaurant restaurant in all) {
            if (restaurant.isOwnedBy(myId)) {
              mine.add(restaurant);
            }
          }

          if (mine.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 48,
                      color: colours.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You have not added a restaurant',
                      style: text.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Own a restaurant? Add it so customers can find and '
                      'review it. You can add more than one if you have '
                      'several branches.',
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

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: mine.length,
            itemBuilder: (BuildContext context, int index) {
              final Restaurant restaurant = mine[index];

              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _view(context, restaurant),
                      child: RestaurantImage(
                        imageUrl: restaurant.imageUrl,
                        height: 130,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: text.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${restaurant.cuisine}  ·  ${restaurant.area}',
                            style: text.bodySmall?.copyWith(
                              color: colours.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (restaurant.rating > 0) ...[
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: colours.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  restaurant.rating.toStringAsFixed(1),
                                  style: text.labelLarge,
                                ),
                              ] else
                                Text(
                                  'No ratings yet',
                                  style: text.labelMedium?.copyWith(
                                    color: colours.onSurfaceVariant,
                                  ),
                                ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: 'Edit',
                                onPressed: () => _edit(context, restaurant),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete',
                                onPressed: () =>
                                    _confirmDelete(context, restaurant),
                              ),
                            ],
                          ),
                        ],
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
