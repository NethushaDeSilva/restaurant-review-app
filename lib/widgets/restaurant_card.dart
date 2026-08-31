import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import 'restaurant_image.dart';

/// One restaurant shown as a wide Material card, image above the text.
///
/// Used by the single-column list layout (phone portrait) and the Home
/// screen. [distanceKm] is only supplied once the user has asked for
/// nearby restaurants and the GPS has returned a position.
class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  final double? distanceKm;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias, // keeps the photo inside the rounded corners
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                RestaurantImage(
                  imageUrl: restaurant.imageUrl,
                  height: 160,
                  heroTag: restaurant.id,
                ),
                if (distanceKm != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colours.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.near_me,
                            size: 13,
                            color: colours.onPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${distanceKm!.toStringAsFixed(1)} km',
                            style: text.labelSmall?.copyWith(
                              color: colours.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: text.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // A newly added listing has no rating until customers
                      // review it, so it shows a "New" chip instead of 0.0.
                      if (restaurant.rating > 0) ...[
                        Icon(Icons.star, size: 18, color: colours.primary),
                        const SizedBox(width: 2),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: text.titleSmall,
                        ),
                      ] else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colours.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'New',
                            style: text.labelSmall?.copyWith(
                              color: colours.onSecondaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${restaurant.cuisine}  ·  ${restaurant.area}',
                    style: text.bodySmall?.copyWith(
                      color: colours.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(restaurant.priceRange, style: text.labelMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The same restaurant shown as a compact card for grid layouts.
///
/// The difference that matters: the image sits inside an Expanded, so it
/// stretches to fill whatever height the grid cell has left after the text.
/// The wide card above uses a fixed image height instead, because in a
/// vertical list there is no cell height to fill.
class RestaurantGridCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  final double? distanceKm;

  const RestaurantGridCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero, // the grid supplies the spacing
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RestaurantImage(
                      imageUrl: restaurant.imageUrl,
                      heroTag: restaurant.id,
                    ),
                  ),
                  if (distanceKm != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colours.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${distanceKm!.toStringAsFixed(1)} km',
                          style: text.labelSmall?.copyWith(
                            color: colours.onPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    restaurant.cuisine,
                    style: text.bodySmall?.copyWith(
                      color: colours.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (restaurant.rating > 0) ...[
                        Icon(Icons.star, size: 14, color: colours.primary),
                        const SizedBox(width: 2),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: text.labelMedium,
                        ),
                      ] else
                        Text(
                          'New',
                          style: text.labelSmall?.copyWith(
                            color: colours.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
