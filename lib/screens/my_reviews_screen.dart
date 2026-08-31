import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'add_review_screen.dart';

/// Every review the signed-in user has written.
///
/// This is where Update and Delete happen. The security rules only let a
/// user change their own reviews, which is why this screen filters on the
/// signed-in uid before showing anything.
class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Review review) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete this review?'),
          content: const Text(
            'This cannot be undone. Your review will be removed for everyone.',
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
      await DatabaseService.deleteReview(review.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Review deleted')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete. Try again.')),
        );
      }
    }
  }

  void _edit(BuildContext context, Review review, Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddReviewScreen(restaurant: restaurant, existingReview: review),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String title, String detail) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: colours.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              detail,
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

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;
    final String myId = AuthService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('My Reviews')),

      // The outer stream supplies restaurants, so each review can show the
      // name of the place it belongs to and open the right edit screen.
      body: StreamBuilder<List<Restaurant>>(
        stream: DatabaseService.restaurantsStream(),
        builder: (context, restaurantSnapshot) {
          if (restaurantSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Restaurant> restaurants = restaurantSnapshot.data ?? [];

          return StreamBuilder<List<Review>>(
            stream: DatabaseService.reviewsStream(),
            builder: (context, reviewSnapshot) {
              if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (reviewSnapshot.hasError) {
                return _buildEmpty(
                  context,
                  'Could not load your reviews',
                  'Check your connection and try again.',
                );
              }

              // Only the reviews written by the signed-in user, and only
              // where the restaurant still exists. A listing that has been
              // deleted leaves its reviews in the database, but there is
              // nothing useful to show for them.
              final List<Review> all = reviewSnapshot.data ?? [];
              final List<Review> mine = [];
              for (final Review review in all) {
                if (review.userId != myId) {
                  continue;
                }
                for (final Restaurant candidate in restaurants) {
                  if (candidate.id == review.restaurantId) {
                    mine.add(review);
                    break;
                  }
                }
              }

              if (mine.isEmpty) {
                return _buildEmpty(
                  context,
                  'You have not written any reviews',
                  'Open a restaurant and tap Write a review to get started.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: mine.length,
                itemBuilder: (BuildContext context, int index) {
                  final Review review = mine[index];

                  // Find the restaurant this review belongs to.
                  Restaurant? restaurant;
                  for (final Restaurant candidate in restaurants) {
                    if (candidate.id == review.restaurantId) {
                      restaurant = candidate;
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  restaurant?.name ?? 'Unknown restaurant',
                                  style: text.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.star,
                                size: 18,
                                color: colours.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                review.rating.toStringAsFixed(1),
                                style: text.titleSmall,
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(review.comment, style: text.bodyMedium),
                          const SizedBox(height: 10),
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
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: 'Edit',
                                onPressed: restaurant == null
                                    ? null
                                    : () => _edit(context, review, restaurant!),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete',
                                onPressed: () => _confirmDelete(context, review),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
