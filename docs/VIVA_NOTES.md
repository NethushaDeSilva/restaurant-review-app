# Viva notes — Colombo Eats

Study notes for the 15-minute demonstration. Delete this file before zipping
the submission if you would rather not include it.

---

## The 30-second summary

> Colombo Eats is a restaurant review app for Colombo. You sign in with
> Firebase Authentication, browse restaurants read live from Firebase
> Realtime Database, open one to see its reviews, and write, edit or delete
> your own. The GPS sorts restaurants by how far away they are. The layout
> changes between a list and a grid depending on orientation and screen size,
> and the whole app follows the phone's light or dark setting.

Learn that. It answers "tell me about your app" and frames everything after.

---

## How the app is put together

```
main.dart
   starts Firebase, then AuthGate decides:
      not signed in  →  LoginScreen  →  RegisterScreen
      signed in      →  MainScreen (bottom navigation bar)
                            ├── HomeScreen           top rated
                            ├── RestaurantsScreen    list/grid + GPS + filter
                            │      └── RestaurantDetailScreen
                            │             └── AddReviewScreen   (create)
                            ├── MyReviewsScreen      edit + delete
                            │      └── AddReviewScreen   (update)
                            └── ProfileScreen        stats + sign out
```

Three folders do three jobs:

| Folder | Holds | Why separate |
|---|---|---|
| `models/` | `Restaurant`, `Review` | Plain Dart classes. Know how to turn a Firebase record into an object and back. |
| `services/` | Auth, Database, Location | Every Firebase and GPS call. Screens stay about layout. |
| `screens/`, `widgets/` | The UI | Screens are whole pages; widgets are pieces reused across pages. |

If asked *why services*: without it, the same `FirebaseDatabase.instance.ref()`
code would be copied into five screens, and changing the data shape would mean
editing all five.

---

## Questions you will almost certainly get

### "Why is this screen stateful and that one stateless?"

A `StatefulWidget` is needed only when something changes **while the screen is
open** and the UI must repaint.

| Screen | Which | Because |
|---|---|---|
| `MainScreen` | Stateful | `_selectedIndex` changes when you tap a tab |
| `RestaurantsScreen` | Stateful | filter value, filter panel open/closed, GPS position |
| `LoginScreen` | Stateful | loading spinner, error message, password visibility |
| `AddReviewScreen` | Stateful | rating, meal, date, saving flag |
| `HomeScreen` | Stateless | nothing on it changes — the `StreamBuilder` handles updates itself |
| `RestaurantDetailScreen` | Stateless | the restaurant is fixed; reviews come from a `StreamBuilder` |

That last row is the interesting one: **a `StreamBuilder` rebuilds itself**, so
a screen whose only changing data comes from Firebase does not need to be
stateful.

### "What does setState actually do?"

It tells Flutter the state variables changed, so schedule a rebuild of this
widget. Flutter compares the new widget tree to the old one and repaints only
what differs.

The trap: mutating a variable **outside** the callback changes memory but the
screen never updates, because Flutter was never told.

```dart
_minRating = 4.5;                        // wrong — no rebuild
setState(() { _minRating = 4.5; });      // right
```

### "Why StreamBuilder and not FutureBuilder?"

A `Future` produces **one** value and finishes. A `Stream` keeps producing
values whenever the data changes.

`DatabaseService.restaurantsStream()` listens to `.onValue`, so if someone adds
a review on another device, Firebase pushes it down and the `StreamBuilder`
rebuilds by itself. A `FutureBuilder` would show a snapshot from when the
screen opened and never update.

This is also how the assignment's "updates live when another device adds a
record" requirement is met — demo it by editing data in the Firebase console
while the app is open.

### "Show me the four CRUD operations"

All four are on **reviews**. Restaurants are reference data loaded once by
console import, which is why the rules make them read-only.

| | Where in the app | Code |
|---|---|---|
| **Create** | Detail → Write a review → Post | `_db.child('reviews').push().set(...)` |
| **Read** | Restaurants list, detail reviews, My Reviews | `.onValue` streams |
| **Update** | My Reviews → edit icon → Save changes | `.child(id).update(...)` |
| **Delete** | My Reviews → delete icon → confirm | `.child(id).remove()` |

Why `push()` for create: it generates a unique key server-side, so two people
writing at the same moment cannot overwrite each other. `set()` on a fixed key
would.

### "Explain your security rules"

```
default            deny everything
restaurants        read: signed in    write: nobody
reviews            read: signed in    write: only the author
```

The write rule reads: *if the record does not exist yet, the `userId` you are
writing must be your own uid; if it does exist, the `userId` already stored
must be your own uid.* That is what stops one user editing another's review.

There are also validations — rating must be a number 1–5, comment 10–400
characters. So even if someone bypassed the app entirely and wrote straight to
the database, bad data is still rejected. **Client-side validation is for
convenience; the rules are the actual protection.**

### "How does the login screen protect the app?"

There is no navigation code doing it. `AuthGate` in `main.dart` listens to
`authStateChanges()`:

- stream gives `null` → show `LoginScreen`
- stream gives a `User` → show `MainScreen`

Signing out pushes `null` down the stream, and the gate rebuilds to the login
screen on its own. Nothing anywhere else has to remember to check.

### "Walk me through the GPS feature"

`LocationService.currentPosition()` checks three things in order, because each
one has a different fix:

1. **Are location services on for the device?** If not, the user must turn them
   on in system settings — asking for permission would be pointless.
2. **Has the app been granted permission?** If not, request it once.
3. **Is it permanently denied?** Then the system dialog will never appear
   again, so the user has to go to Settings themselves.

Each failure throws a `LocationException` carrying a sentence written for the
user, which `RestaurantsScreen` shows in a red bar. The app never crashes and
never silently does nothing.

**Demo both paths** — allow it once to show the distance badges, then revoke
the permission in Android settings and tap again to show the error handling.
The rubric asks for denial handled gracefully, so showing only the happy path
leaves marks on the table.

### "How does the layout respond to screen size?"

```dart
final double shortestSide = MediaQuery.of(context).size.shortestSide;
final bool isTablet = shortestSide >= 600;
```

`shortestSide` is the narrower dimension, so it does not change when the device
rotates. That separates two different questions:

- **`shortestSide`** → is this a phone or a tablet?
- **`OrientationBuilder`** → is it being held sideways?

If you used plain `width` instead, a phone in landscape is over 600dp wide and
would be mistaken for a tablet. Expect to be asked this — it is the one line
that shows the responsive work is deliberate.

|  | portrait | landscape |
|---|---|---|
| phone | 1 column, `ListView.builder` | 2 columns, `GridView.builder` |
| tablet | 2 columns | 3 columns |

### "Which animation did you implement?"

Two.

**Hero** — the restaurant photo. The card and the detail screen both wrap the
image in `Hero` with `tag: restaurant.id`. When the route changes Flutter finds
the matching tags and flies the image between the two positions. No animation
controller needed; matching tags are the whole mechanism.

**AnimatedCrossFade** — the filter panel. It fades between the panel and an
empty box and animates the height difference, so the panel slides open instead
of snapping.

### "Why ListView.builder rather than ListView?"

`ListView` builds every child immediately. `ListView.builder` builds each item
only as it scrolls into view.

With 8 restaurants there is no visible difference — be honest about that. The
point is that it does not change as the list grows: from Firebase this could be
hundreds of records, and `builder` keeps memory flat and scrolling smooth
regardless.

Note `HomeScreen` deliberately uses a plain loop, because it shows a fixed 4
items and lazy loading would be pointless there.

### "How does the detail screen get its data?"

Through the constructor. `Navigator.push` builds it and hands the object
straight in:

```dart
Navigator.push(context, MaterialPageRoute(
  builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
));
```

Not by passing an id and looking it up again — the calling screen already has
the object.

### "How does dark mode work?"

`MaterialApp` gets three properties: `theme`, `darkTheme`, and
`themeMode: ThemeMode.system`. The last one makes Flutter read the OS setting
and pick the matching one, and re-pick when it changes.

Both themes are built by `ColorScheme.fromSeed` from a single colour. It
generates a full Material 3 palette with contrast ratios that meet
accessibility requirements, which is why no widget hard-codes a colour — they
all read from `Theme.of(context).colorScheme`.

### "How does form validation work?"

Three parts:

1. `GlobalKey<FormState>` on the `Form` gives access to its state
2. Each `TextFormField` has a `validator` returning an error string or `null`
3. `_formKey.currentState!.validate()` runs every validator and returns false
   if any failed

Email uses a regular expression: `^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$` —
characters, an `@`, a domain, a dot, and at least two letters.

Controllers are disposed of in `dispose()`. If asked why: a
`TextEditingController` holds a listener list and memory that is not released
when the widget is destroyed, so not disposing leaks it.

---

## If asked to live code

Rehearse these three. They are the most likely asks and each is a few lines.

**"Add a field to the review form."** Add it to the `Review` class, to
`toMap`/`fromMap`, a state variable in `_AddReviewScreenState`, the widget in
the form, and include it when building the `Review` in `_save()`.

**"Make the list sort differently."** In `_applyFilters`, change the
comparator: `matches.sort((a, b) => b.rating.compareTo(a.rating));`

**"Add a fifth tab."** A new screen class, add it to `_screens` in
`MainScreen`, add a `NavigationDestination`. Stress that the list index and
destination index must line up.

---

## Be honest about limitations

Assessors respect a student who knows the weak points more than one who claims
there are none:

- Restaurants cannot be added from the app — they are reference data. All four
  CRUD operations run on reviews.
- Distance is straight-line, not driving distance.
- A user can post more than one review for the same restaurant.
- Restaurant photos are Unsplash URLs, so an offline device shows the fallback
  icon.
- The rating shown on a restaurant is fixed data, not recalculated from the
  reviews users write. That would be the obvious next feature.

---

## The night before

- [ ] `flutter run` works from a cold start with no errors
- [ ] Emulator location set to Colombo (6.9271, 79.8612)
- [ ] A second test account registered, so you can show whose reviews are editable
- [ ] Two or three reviews already written, so no screen is empty
- [ ] Firebase console open in a browser tab for the live-sync demo
- [ ] Tablet AVD created for the screen-size layouts
- [ ] Test plan filled in and in the document
- [ ] You can find any file in under five seconds
