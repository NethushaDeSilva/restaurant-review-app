import 'package:flutter/material.dart';

import '../../models/restaurant.dart';
import '../../models/review.dart';
import '../../services/database_service.dart';
import '../../utils/ratings.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_detail_screen.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  double _minRating = 0;
  bool _showFilter = false;
  String _searchName = '';

  void _openDetail(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );
  }

  List<Restaurant> _applyFilters(
    List<Restaurant> all,
    Map<String, ({double average, int count})> ratings,
  ) {
    final List<Restaurant> matches = all.where((restaurant) {
      final double average = ratings[restaurant.id]?.average ?? 0;
      return average >= _minRating &&
          (_searchName.isEmpty || restaurant.name.toLowerCase() == _searchName);
    }).toList();

    return matches;
  }

  int _columnCount(Orientation orientation) {
    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isTablet = shortestSide >= 600;

    if (orientation == Orientation.portrait) {
      return isTablet ? 2 : 1;
    }
    return isTablet ? 3 : 2;
  }

  Widget _buildFilterPanel(int total, int shown) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 250),
      crossFadeState: _showFilter
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Container(
        width: double.infinity,
        color: colours.surfaceContainerHighest,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Minimum rating', style: text.labelLarge),
                const Spacer(),
                Text(
                  _minRating == 0
                      ? 'Any'
                      : '${_minRating.toStringAsFixed(1)} and above',
                  style: text.labelLarge?.copyWith(color: colours.primary),
                ),
              ],
            ),
            Slider(
              value: _minRating,
              min: 0,
              max: 5,
              divisions: 10,
              label: _minRating.toStringAsFixed(1),
              onChanged: (double value) {
                setState(() => _minRating = value);
              },
            ),
            Text(
              '$shown of $total restaurants shown',
              style: text.bodySmall?.copyWith(color: colours.onSurfaceVariant),
            ),
          ],
        ),
      ),
      secondChild: const SizedBox(width: double.infinity),
    );
  }

  Widget _buildMessage(IconData icon, String title, String detail) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colours.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: colours.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    List<Restaurant> visible,
    Map<String, ({double average, int count})> ratings,
  ) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final int columns = _columnCount(orientation);

        if (columns == 1) {
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: visible.length,
            itemBuilder: (BuildContext context, int index) {
              final Restaurant restaurant = visible[index];
              return RestaurantCard(
                restaurant: restaurant,
                reviewCount: ratings[restaurant.id]?.count ?? 0,
                averageRating: ratings[restaurant.id]?.average,
                onTap: () => _openDetail(restaurant),
              );
            },
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          itemCount: visible.length,
          itemBuilder: (BuildContext context, int index) {
            final Restaurant restaurant = visible[index];
            return RestaurantGridCard(
              restaurant: restaurant,
              reviewCount: ratings[restaurant.id]?.count ?? 0,
              averageRating: ratings[restaurant.id]?.average,
              onTap: () => _openDetail(restaurant),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by restaurant name',
                hintText: 'Enter the full name',
              ),
              onChanged: (value) =>
                  setState(() => _searchName = value.trim().toLowerCase()),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showFilter ? Icons.filter_list_off : Icons.filter_list),
            tooltip: 'Filter by rating',
            onPressed: () => setState(() => _showFilter = !_showFilter),
          ),
        ],
      ),

      body: StreamBuilder<List<Restaurant>>(
        stream: DatabaseService.restaurantsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildMessage(
              Icons.cloud_off,
              'Could not load restaurants',
              'Check your internet connection and try again.',
            );
          }

          final List<Restaurant> all = snapshot.data ?? [];

          if (all.isEmpty) {
            return _buildMessage(
              Icons.restaurant_outlined,
              'No restaurants yet',
              'The restaurant list has not been added to the database.',
            );
          }

          return StreamBuilder<List<Review>>(
            stream: DatabaseService.reviewsStream(),
            builder: (context, reviewSnapshot) {
              if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (reviewSnapshot.hasError) {
                return _buildMessage(
                  Icons.cloud_off,
                  'Could not load ratings',
                  'Check your internet connection and try again.',
                );
              }

              final Map<String, ({double average, int count})> ratings =
                  ratingsByRestaurant(reviewSnapshot.data ?? []);
              final List<Restaurant> visible = _applyFilters(all, ratings);

              return Column(
                children: [
                  _buildFilterPanel(all.length, visible.length),
                  Expanded(
                    child: visible.isEmpty
                        ? _buildMessage(
                            Icons.search_off,
                            'No restaurants match',
                            _searchName.isEmpty
                                ? 'Lower the minimum rating to see more results.'
                                : 'Check the full name or lower the minimum rating.',
                          )
                        : _buildList(visible, ratings),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
