# Colombo Eats

Android restaurant review app built with Flutter, Firebase Authentication,
Firebase Realtime Database and device GPS.

## Find the code

**Homepage UI:** [lib/ui/home/home_screen.dart](lib/ui/home/home_screen.dart).

| Folder | Contents |
|---|---|
| [lib/ui/](lib/ui/) | Screens grouped by feature, shared widgets and theme |
| [lib/services/](lib/services/) | Authentication, database operations and GPS |
| [lib/models/](lib/models/) | Restaurant and review data classes |
| [lib/utils/](lib/utils/) | Rating calculations and shared email validation |
| [firebase/](firebase/) | Database rules and initial restaurant data |
| [test/](test/) | Automated tests |

Start with [lib/main.dart](lib/main.dart) for app startup and the login gate.
Use the [screen and function index](lib/README.md) during a demo.

In VS Code, press **Ctrl+P** and type a filename such as `home_screen.dart`,
`add_review_screen.dart` or `database_service.dart`.

## Generated files and platform folders

`.dart_tool/` and `build/` are generated tooling/build output, not app screens.
The workspace Explorer settings hide them and other generated caches without
deleting them. Change `files.exclude` in `.vscode/settings.json` to show them.
An already-open generated file can still remain in an editor tab; close that tab.

`android/` contains the Android launcher, permissions and build configuration.
The other platform folders are Flutter scaffolding; Firebase is currently
configured for Android only. Keep platform folders in their standard locations.

## Run and check

With an Android device or emulator connected:

```sh
flutter run
flutter test
flutter analyze
```
