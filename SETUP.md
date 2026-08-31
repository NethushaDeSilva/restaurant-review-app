# Setup — what has to be done before the app will run

The Dart code is finished. It cannot start until a Firebase project exists and
`google-services.json` is in place, because `main()` calls
`Firebase.initializeApp()` before anything else.

Work through these in order. **The order matters** — see the warning at step 4.

---

## 1. Create the Firebase project

1. Go to <https://console.firebase.google.com>
2. **Add project** → name it `colombo-eats` (any name works)
3. Turn **Google Analytics off** — it is not needed and adds setup steps
4. Wait for it to finish, then **Continue**

## 2. Turn on Email/Password sign-in

1. Left sidebar → **Build** → **Authentication** → **Get started**
2. **Sign-in method** tab → **Email/Password**
3. Enable the first toggle only (not "Email link") → **Save**

## 3. Create the Realtime Database

1. Left sidebar → **Build** → **Realtime Database** → **Create Database**
2. Location: **Singapore (asia-southeast1)** — closest to Sri Lanka
3. Start in **locked mode**. The real rules go in at step 6.

## 4. Register the Android app

> ⚠️ **Do this after step 3, not before.**
> `google-services.json` only contains the database URL if the Realtime
> Database already exists when you download it. Download it too early and the
> app will start but every database read will fail with a confusing error. If
> that happens, just download the file again from Project Settings.

1. Project overview → the **Android** icon
2. **Android package name** — this must match exactly:
   ```
   com.example.restaurant_review_app
   ```
   (It is `applicationId` in `android/app/build.gradle.kts`.)
3. Nickname and SHA-1 can be left blank
4. **Register app** → **Download google-services.json**
5. Put the file here:
   ```
   android/app/google-services.json
   ```
6. Skip the remaining SDK instructions on screen — the Gradle changes are
   already in this repo.

## 5. Load the restaurant data

1. **Realtime Database** → **Data** tab
2. Click the **⋮** menu at the top right of the data panel → **Import JSON**
3. Choose `firebase/restaurants.json` from this repo
4. Confirm

You should now see a `restaurants` node with `r1` to `r8` under it.

> Import replaces everything at the node you are on. Make sure you are at the
> **root** (the line showing your database URL), not inside a child.

## 6. Publish the security rules

1. **Realtime Database** → **Rules** tab
2. Delete what is there and paste the entire contents of
   `firebase/database_rules.json`
3. **Publish**

What these rules do, in case you are asked:

| Node | Read | Write |
|---|---|---|
| everything by default | denied | denied |
| `restaurants` | signed-in users only | nobody (reference data, loaded by import) |
| `reviews` | signed-in users only | only the user whose `userId` matches the record |

They also validate that a rating is a number between 1 and 5 and that a
comment is 10–400 characters, so bad data cannot be written even if the app's
own validation were bypassed.

## 7. Run it

```bash
flutter run -d emulator-5554
```

The first build after adding Firebase takes several minutes — Gradle is
downloading the Firebase SDKs. Later builds are fast again.

Register an account, and you are in.

---

## Testing the location feature on an emulator

An emulator has no real GPS, so you have to give it a position:

1. Click the **⋯** (More) button on the emulator's side toolbar
2. **Location** in the left list
3. Enter Colombo:
   - Latitude `6.9271`
   - Longitude `79.8612`
4. **Set Location**

Now open the **Restaurants** tab and tap the ➤ arrow icon in the app bar. The
first tap shows the Android permission dialog. Allow it, and each card gets a
distance badge and the list re-sorts nearest first.

Tap **Deny** instead and you get a red bar explaining what happened rather than
a crash — that is the "permission denial handled gracefully" requirement, and
it is worth demonstrating both ways in the viva.

---

## If something goes wrong

**`No Firebase App '[DEFAULT]' has been created`**
`google-services.json` is missing or in the wrong folder. It goes in
`android/app/`, not `android/`.

**App runs but restaurants never load, or a permission-denied error**
Either the rules were not published (step 6), or `google-services.json` was
downloaded before the database existed (step 4). Re-download it from
**Project Settings → Your apps → google-services.json**.

**`Default FirebaseApp is not initialized`**
The Gradle plugin did not apply. Run `flutter clean`, then `flutter run` again.

**Build fails mentioning minSdk or API level**
`android/app/build.gradle.kts` sets `minSdk = 23` for Firebase Auth. If you
have changed it back, set it to 23 again.
