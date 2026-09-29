# Screen and function index

UI files live in `ui/`, grouped by feature. Their `build()` methods and private
widget helpers define the layout. Button handlers and form state stay with their
screen; Firebase and GPS calls live in `services/`.

## Open a page

| Demo request | File |
|---|---|
| Homepage | [ui/home/home_screen.dart](ui/home/home_screen.dart) |
| Login | [ui/auth/login_screen.dart](ui/auth/login_screen.dart) |
| Registration | [ui/auth/register_screen.dart](ui/auth/register_screen.dart) |
| Restaurant list, rating filter and nearby button | [ui/restaurants/restaurants_screen.dart](ui/restaurants/restaurants_screen.dart) |
| Restaurant details and customer reviews | [ui/restaurants/restaurant_detail_screen.dart](ui/restaurants/restaurant_detail_screen.dart) |
| My Reviews | [ui/my_reviews/my_reviews_screen.dart](ui/my_reviews/my_reviews_screen.dart) |
| Write or edit a review | [ui/my_reviews/add_review_screen.dart](ui/my_reviews/add_review_screen.dart) |
| My Restaurants | [ui/my_restaurants/my_restaurants_screen.dart](ui/my_restaurants/my_restaurants_screen.dart) |
| Add or edit a restaurant | [ui/my_restaurants/add_restaurant_screen.dart](ui/my_restaurants/add_restaurant_screen.dart) |
| Profile and review statistics | [ui/profile/profile_screen.dart](ui/profile/profile_screen.dart) |
| Bottom navigation and tablet navigation rail | [ui/main_screen.dart](ui/main_screen.dart) |

## Open the functionality

| Demo request | File and method |
|---|---|
| App startup and login gate | [main.dart](main.dart): `main`, `AuthGate.build` |
| Sign in, register or sign out | [services/auth_service.dart](services/auth_service.dart): `signIn`, `register`, `signOut` |
| Read live data from Firebase | [services/database_service.dart](services/database_service.dart): `restaurantsStream`, `reviewsStream` |
| Save or delete records | [services/database_service.dart](services/database_service.dart): `addReview`, `updateReview`, `deleteReview`, `addRestaurant`, `updateRestaurant`, `deleteRestaurant` |
| Review form validation and save button | [ui/my_reviews/add_review_screen.dart](ui/my_reviews/add_review_screen.dart): `_validateComment`, `_save` |
| Restaurant form validation and save button | [ui/my_restaurants/add_restaurant_screen.dart](ui/my_restaurants/add_restaurant_screen.dart): `_save` and field validators |
| Location permissions and GPS | [services/location_service.dart](services/location_service.dart): `currentPosition`, `distanceInKm` |
| Rating averages and counts | [utils/ratings.dart](utils/ratings.dart): `ratingsByRestaurant` |
| Shared email validation | [utils/form_validators.dart](utils/form_validators.dart): `validateEmail` |
| Restaurant fields and ownership helper | [models/restaurant.dart](models/restaurant.dart): `Restaurant`, `isOwnedBy` |
| Review fields | [models/review.dart](models/review.dart): `Review` |
| Database access rules | [../firebase/database_rules.json](../firebase/database_rules.json) |

## Shared appearance

| Part | File |
|---|---|
| Restaurant list/grid cards | [ui/widgets/restaurant_card.dart](ui/widgets/restaurant_card.dart) |
| Photo loading, fallback and Hero transition | [ui/widgets/restaurant_image.dart](ui/widgets/restaurant_image.dart) |
| Colours and light/dark themes | [ui/theme/app_theme.dart](ui/theme/app_theme.dart) |

`firebase_options.dart` is generated Firebase configuration. Files under
`.dart_tool/`, including `web_plugin_registrant.dart`, are generated tooling code.
Neither location contains the app's pages.

During the demo, use **Ctrl+P** to open a filename directly. For example, type
`home_screen.dart` for the homepage, then use **Ctrl+F** for `build` or a visible
label to find the relevant widget.
