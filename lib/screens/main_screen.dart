import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'my_reviews_screen.dart';
import 'profile_screen.dart';
import 'restaurants_screen.dart';

/// The shell that holds the app's navigation.
///
/// This is a StatefulWidget because the selected tab is state: it changes
/// while the app runs and the UI has to repaint when it does. _selectedIndex
/// remembers which tab is open, and setState tells Flutter to rebuild.
///
/// The navigation widget itself changes with screen size: a phone gets the
/// familiar bottom NavigationBar, but on a tablet-width device that bar would
/// sit far from the thumb and waste the side space, so a NavigationRail is
/// used instead. Both share the same destinations and the same
/// _selectedIndex, so switching between them at a size boundary (e.g.
/// rotating a tablet) never loses the current tab.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  /// The four screens the navigation switches between.
  /// The list index matches the navigation destination index.
  static const List<Widget> _screens = [
    HomeScreen(),
    RestaurantsScreen(),
    MyReviewsScreen(),
    ProfileScreen(),
  ];

  static const List<String> _labels = [
    'Home',
    'Restaurants',
    'My Reviews',
    'Profile',
  ];

  static const List<IconData> _icons = [
    Icons.home_outlined,
    Icons.restaurant_outlined,
    Icons.rate_review_outlined,
    Icons.person_outline,
  ];

  static const List<IconData> _selectedIcons = [
    Icons.home,
    Icons.restaurant,
    Icons.rate_review,
    Icons.person,
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // shortestSide is the width of the device in portrait, whichever way it
    // is currently held, which is the standard way to ask "phone or tablet"
    // independent of rotation.
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (int i = 0; i < _labels.length; i++)
                  NavigationRailDestination(
                    icon: Icon(_icons[i]),
                    selectedIcon: Icon(_selectedIcons[i]),
                    label: Text(_labels[i]),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          for (int i = 0; i < _labels.length; i++)
            NavigationDestination(
              icon: Icon(_icons[i]),
              selectedIcon: Icon(_selectedIcons[i]),
              label: _labels[i],
            ),
        ],
      ),
    );
  }
}
