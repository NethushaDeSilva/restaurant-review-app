import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/restaurant.dart';
import '../../models/review.dart';
import '../../services/database_service.dart';
import '../../services/location_service.dart';
import '../../utils/ratings.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_detail_screen.dart';

/// Live restaurant list with name/rating filtering and optional distance sorting.
class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  double _minRating = 0;
  bool _showFilter = false;
  String _searchName = '';

  /// Null until the user taps the nearby button and the GPS responds.
  Position? _position;
  bool _loadingLocation = false;
  String? _locationMessage;

  void _openDetail(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );
  }

  /// Requests location and displays any failure without clearing the last position.
  Future<void> _findNearby() async {
    setState(() {
      _loadingLocation = true;
      _locationMessage = null;
    });

    try {
      final Position position = await LocationService.currentPosition();
      if (mounted) {
        setState(() {
          _position = position;
          _locationMessage = 'Sorted by distance from you';
        });
      }
    } on LocationException catch (error) {
      if (mounted) {
        setState(() => _locationMessage = error.message);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _locationMessage = 'Could not read your location.');
      }
    } finally {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  double? _distanceTo(Restaurant restaurant) {
    final Position? position = _position;
    if (position == null) {
      return null;
    }
    return LocationService.distanceInKm(
      position.latitude,
      position.longitude,
      restaurant.latitude,
      restaurant.longitude,
    );
  }

  /// Unreviewed restaurants pass only the zero-minimum filter.
  /// Sorts by distance when a position is available.
  List<Restaurant> _applyFilters(
    List<Restaurant> all,
    Map<String, ({double average, int count})> ratings,
  ) {
    final List<Restaurant> matches = all.where((restaurant) {
      final double average = ratings[restaurant.id]?.average ?? 0;
      return average >= _minRating &&
          (_searchName.isEmpty || restaurant.name.toLowerCase() == _searchName);
    }).toList();

    if (_position != null) {
      matches.sort((a, b) {
        final double distanceA = _distanceTo(a) ?? 0;
        final double distanceB = _distanceTo(b) ?? 0;
        return distanceA.compareTo(distanceB);
      });
    }

    return matches;
  }

  /// Uses shortestSide to distinguish tablets independently of rotation.
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

  Widget _buildLocationBar() {
    if (_locationMessage == null) {
      return const SizedBox.shrink();
    }

    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;
    final bool isSuccess = _position != null;

    return Container(
      width: double.infinity,
      color: isSuccess ? colours.primaryContainer : colours.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.near_me : Icons.location_off,
            size: 18,
            color: isSuccess
                ? colours.onPrimaryContainer
                : colours.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _locationMessage!,
              style: text.bodySmall?.copyWith(
                color: isSuccess
                    ? colours.onPrimaryContainer
                    : colours.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: () => setState(() => _locationMessage = null),
          ),
        ],
      ),
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
                distanceKm: _distanceTo(restaurant),
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
              distanceKm: _distanceTo(restaurant),
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
            icon: _loadingLocation
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.near_me_outlined),
            tooltip: 'Sort by distance from me',
            onPressed: _loadingLocation ? null : _findNearby,
          ),
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

          // Filter and display using live review averages.
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
                  _buildLocationBar(),
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
