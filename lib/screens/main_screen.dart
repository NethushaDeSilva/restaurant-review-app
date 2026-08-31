import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'my_reviews_screen.dart';
import 'profile_screen.dart';
import 'restaurants_screen.dart';

/// The shell that holds the fixed bottom navigation bar.
///
/// This is a StatefulWidget because the selected tab is state: it changes
/// while the app runs and the UI has to repaint when it does. _selectedIndex
/// remembers which tab is open, and setState tells Flutter to rebuild.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  /// The four screens the navigation bar switches between.
  /// The list index matches the navigation destination index.
  static const List<Widget> _screens = [
    HomeScreen(),
    RestaurantsScreen(),
    MyReviewsScreen(),
    ProfileScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Restaurants',
          ),
          NavigationDestination(
            icon: Icon(Icons.rate_review_outlined),
            selectedIcon: Icon(Icons.rate_review),
            label: 'My Reviews',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
