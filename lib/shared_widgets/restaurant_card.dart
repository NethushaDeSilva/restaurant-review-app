import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import 'restaurant_image.dart';

/// List card using live review statistics, not the stored restaurant rating.
/// [averageRating] must be supplied when [reviewCount] is positive.
class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  final int reviewCount;
  final double? distanceKm;
  final double? averageRating;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    required this.reviewCount,
    this.distanceKm,
    this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
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
                      if (reviewCount > 0) ...[
                        Icon(Icons.star, size: 18, color: colours.primary),
                        const SizedBox(width: 2),
                        Text(
                          '${averageRating!.toStringAsFixed(1)} ($reviewCount)',
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

/// Grid card whose photo fills the remaining cell height.
/// [averageRating] must be supplied when [reviewCount] is positive.
class RestaurantGridCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  final int reviewCount;
  final double? distanceKm;
  final double? averageRating;

  const RestaurantGridCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    required this.reviewCount,
    this.distanceKm,
    this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
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
                      if (reviewCount > 0) ...[
                        Icon(Icons.star, size: 14, color: colours.primary),
                        const SizedBox(width: 2),
                        Text(
                          '${averageRating!.toStringAsFixed(1)} ($reviewCount)',
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
