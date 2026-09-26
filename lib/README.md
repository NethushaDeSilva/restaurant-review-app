# lib/ map

- `main.dart` — app entry point and the AuthGate that switches between the login screen and the main app.
- `firebase_options.dart` — generated Firebase configuration, read by `main.dart`.
- `theme/` — the single seed colour and the light/dark ThemeData built from it, used app-wide.
- `models/` — `Restaurant` and `Review`, the two Firebase record types, with their `fromMap`/`toMap` conversions.
- `services/` — all Firebase Auth, Firebase Realtime Database, and GPS calls, kept out of the screens.
- `utils/` — `ratingsByRestaurant`, the pure function that averages live reviews into a restaurant's rating.
- `shared_widgets/` — `RestaurantCard`/`RestaurantGridCard` and `RestaurantImage`, reused across the Home, Restaurants, and My Restaurants screens.
- `screens/main_screen.dart` — the navigation shell (NavigationBar on phones, NavigationRail on tablets) that hosts the four main tabs.
- `screens/auth/` — the login and register screens, shown before a user is signed in.
- `screens/home/` — the Home tab: top-rated restaurants.
- `screens/restaurants/` — the Restaurants tab and the restaurant detail page it opens into.
- `screens/my_reviews/` — the My Reviews tab and the add/edit review form it opens into.
- `screens/my_restaurants/` — the My Restaurants screen (reached from Profile) and the add/edit restaurant form it opens into.
- `screens/profile/` — the Profile tab: account info, stats, and sign out.
