import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'my_restaurants_screen.dart';

/// The signed-in user's own page, with the sign-out button.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool? shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign out?'),
          content: const Text('You will need to sign in again to write reviews.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true) {
      // main.dart is listening to authChanges() and shows the login screen
      // as soon as this completes.
      await AuthService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    final User? user = AuthService.currentUser;
    final String name = user?.displayName ?? 'Guest';
    final String email = user?.email ?? '';
    final String initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: colours.primaryContainer,
                        child: Text(
                          initial,
                          style: text.headlineMedium?.copyWith(
                            color: colours.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: text.titleLarge),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: text.bodySmall?.copyWith(
                                color: colours.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Counts come from the same live review stream, so they update
              // straight away when a review is added or deleted.
              StreamBuilder<List<Review>>(
                stream: DatabaseService.reviewsStream(),
                builder: (context, snapshot) {
                  final List<Review> all = snapshot.data ?? [];
                  final String myId = user?.uid ?? '';

                  int count = 0;
                  double total = 0;
                  for (final Review review in all) {
                    if (review.userId == myId) {
                      count = count + 1;
                      total = total + review.rating;
                    }
                  }
                  final double average = count == 0 ? 0 : total / count;

                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Reviews written',
                          value: count.toString(),
                          icon: Icons.rate_review_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Average rating given',
                          value: count == 0 ? '-' : average.toStringAsFixed(1),
                          icon: Icons.star_outline,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.storefront_outlined),
                      title: const Text('My Restaurants'),
                      subtitle: const Text(
                        'Add and manage restaurants you own',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyRestaurantsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.brightness_6_outlined),
                      title: Text('Appearance'),
                      subtitle: Text('Follows your device light/dark setting'),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('About'),
                      subtitle: Text('Colombo Eats · version 1.0.0'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.logout, color: colours.error),
                      title: Text(
                        'Sign out',
                        style: TextStyle(color: colours.error),
                      ),
                      onTap: () => _confirmSignOut(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small reusable tile showing one number about the user.
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colours.primary),
            const SizedBox(height: 10),
            Text(value, style: text.headlineSmall),
            const SizedBox(height: 2),
            Text(
              label,
              style: text.bodySmall?.copyWith(color: colours.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
