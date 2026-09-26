# Test Plan — Colombo Eats

Manual testing carried out on an Android emulator (Pixel 6, API 34) and
recorded below. Fill the Actual result and Date columns in as you run each
case, and paste the completed table into the submission document.

**Environment**

| Item | Value |
|---|---|
| Device | Android Emulator — Pixel 6, API 34 |
| Flutter | 3.47.0 |
| Dart | 3.13.0 |
| Backend | Firebase Realtime Database (asia-southeast1) |
| Build | Debug |

---

## 1. Authentication

| ID | Steps | Expected | Actual | Pass/Fail | Date |
|---|---|---|---|---|---|
| A1 | Register → fill all fields → Create account | Account created, app opens on Home tab | | | |
| A2 | Enter `nethusha.com` → submit | Field error "Enter a valid email address"; nothing sent to Firebase | | | |
| A3 | Enter `123` → submit | Field error "Password must be at least 6 characters" | | | |
| A4 | Enter different confirm password | Field error "Passwords do not match" | | | |
| A5 | Use an email already registered | Red bar: "An account already exists with that email" | | | |
| A6 | Enter valid credentials → Sign in | Opens on Home tab | | | |
| A7 | Enter valid email, wrong password | Red bar: "Email or password is incorrect" | | | |
| A8 | Tap Sign in with both fields blank | Both fields show validation errors | | | |
| A9 | Sign in → close app → reopen | Opens signed in, no login screen | | | |
| A10 | Profile → Sign out → confirm | Returns to login screen | | | |
| A11 | Profile → Sign out → Cancel | Stays signed in | | | |

## 2. Navigation

| ID | Steps | Expected | Actual | Pass/Fail | Date |
|---|---|---|---|---|---|
| N1 | Tap each destination in the bottom bar | Correct screen shown, icon fills in | | | |
| N2 | Restaurants → tap any card | Detail screen opens with that restaurant | | | |
| N3 | Detail → back arrow | Returns to the list, scroll position kept | | | |
| N4 | Login → Register | Register screen opens | | | |
| N5 | Register → back arrow | Returns to login | | | |

## 3. Firebase CRUD — reviews

| ID | Steps | Expected | Actual | Pass/Fail | Date |
|---|---|---|---|---|---|
| C1 | Open Restaurants tab | 8 restaurants load from Firebase | | | |
| C2 | Detail → Write a review → fill → Post | Snackbar "Review posted"; appears under Reviews immediately | | | |
| C3 | My Reviews tab | The new review is listed | | | |
| C4 | My Reviews → edit icon → change rating → Save changes | Snackbar "Review updated"; new values shown | | | |
| C5 | My Reviews → delete icon → Delete | Snackbar "Review deleted"; row disappears | | | |
| C6 | Delete icon → Cancel | Review is not deleted | | | |
| C7 | Add a review in the Firebase console while the app is open | Appears in the app without any refresh | | | |
| C8 | Sign in as a second user, view a restaurant | Other users' reviews visible but no edit/delete buttons on My Reviews | | | |
| C9 | Open Restaurants on a cold start | Spinner shown before the list appears | | | |
| C10 | Turn off emulator network → open Restaurants | "Could not load restaurants" message, no crash | | | |
| C11 | Set the rating filter to 5.0 | "No restaurants match" message | | | |
| C12 | Firebase console → Rules → Simulator → write to `/reviews` unauthenticated | Simulation denied | | | |

## 4. Firebase CRUD — restaurants

| ID | Steps | Expected | Actual | Pass/Fail | Date |
|---|---|---|---|---|---|
| R1 | Profile → My Restaurants → Add restaurant → fill form → Use my current location → Add restaurant | Snackbar "Restaurant added"; listing appears in the Restaurants tab with a "New" chip | | | |
| R2 | My Restaurants → edit icon → change the name → Save changes | Snackbar "Restaurant updated"; new name shown everywhere the restaurant appears | | | |
| R3 | My Restaurants → delete icon → Delete | Snackbar "Restaurant deleted"; listing disappears from Restaurants and Home; any reviews that were written about it are not deleted and simply stop being displayed | | | |
| R4 | Add restaurant → leave the photo link blank → Add restaurant | Field error "Paste a photo link for your restaurant" | | | |
| R5 | Add restaurant → type a description under 20 characters | Field error "Please write at least 20 characters" | | | |
| R6 | Add restaurant → do not tap "Use my current location" → Add restaurant | Inline error: "Set the restaurant location before saving." — save is blocked | | | |

## 5. Ownership rules

| ID | Steps | Expected | Actual | Pass/Fail | Date |
|---|---|---|---|---|---|
| O1 | Owner cannot review their own restaurant (UI) | Open a restaurant you added yourself | No "Write a review" floating button; a banner reads "This is your restaurant. Owners cannot review their own listings." | | | |
| O2 | Owner cannot review their own restaurant (rules) | While signed in as the owner, attempt a direct write to `/reviews` with `restaurantId` set to your own restaurant and `userId` set to your own uid (Firebase console Rules Simulator, or a REST call with your ID token) | Write is rejected — `PERMISSION_DENIED` | | | |
| O3 | Owner cannot set their own rating (rules) | While signed in as the owner, attempt a direct write to `/restaurants/{yourId}/rating` setting any value other than the current one (Rules Simulator or REST call) | Write is rejected — `PERMISSION_DENIED`, both for a non-zero value on create and for any change on update | | | |
| O4 | Live rating updates after a review is posted | Note a restaurant's current rating (or "New" if unreviewed) → post a review for it as a different account → return to the Restaurants list and the restaurant's detail page | The average and review count update immediately to reflect the new review, with no app restart | | | |

## 6. Form validation

| ID | Steps | Expected | Actual | Pass/Fail | Date |
|---|---|---|---|---|---|
| F1 | Post review with blank comment | "Write a few words about your visit" | | | |
| F2 | Enter `Good` as the comment | "Please write at least 10 characters" | | | |
| F3 | Drag the rating slider from 1.0 to 5.0 | Value updates live next to the slider | | | |
| F4 | Open the meal dropdown, choose Lunch | Selection shown in the field | | | |
| F5 | Tap the date field, choose a past date | Date shown as e.g. "12 Aug 2026" | | | |
| F6 | Open the date picker | Dates after today cannot be selected | | | |
| F7 | Type past 400 characters in the review comment | Counter stops at 400 | | | |
| F8 | My Reviews → edit | Rating, meal and comment already filled in | | | |

## 7. Hardware sensor — GPS

| ID | Steps | Expected | Actual | Pass/Fail | Date |
|---|---|---|---|---|---|
| G1 | First tap of the ➤ icon | Android permission dialog appears | | | |
| G2 | Allow | Distance badges appear; list sorts nearest first | | | |
| G3 | Deny | Red bar explaining distances will not show; **no crash** | | | |
| G4 | Emulator settings → Location off → tap ➤ | Message "Location is switched off on this device" | | | |
| G5 | Set emulator to 6.9271, 79.8612 | Colombo 01–07 restaurants all within a few km | | | |
| G6 | Tap × on the location bar | Bar closes, distances stay | | | |

## 8. Layout, theme and animation

| ID | Steps | Expected | Actual | Pass/Fail | Date |
|---|---|---|---|---|---|
| L1 | Device Settings → Display → Dark theme | App recolours with no restart | | | |
| L2 | Turn dark theme back off | App returns to light palette | | | |
| L3 | Restaurants tab, upright | Single-column list of wide cards | | | |
| L4 | Rotate | Two-column grid of compact cards | | | |
| L5 | Run on a Pixel Tablet AVD, portrait | NavigationRail on the left instead of the bottom bar; two-column grid | | | |
| L6 | Rotate the tablet | Three-column grid; NavigationRail remains | | | |
| L7 | Open a restaurant upright | Photo on top, details underneath | | | |
| L8 | Rotate | Photo on the left, details scroll on the right | | | |
| L9 | Tap a card | Photo expands from the card into the detail screen | | | |
| L10 | Tap the filter icon | Panel slides open rather than snapping | | | |
| L11 | Break an imageUrl in Firebase | Grey box with a fork icon, no red error box | | | |
| L12 | Set a restaurant name to 60 characters | Name truncates with "…", layout does not break | | | |

---

## Summary

| Section | Cases | Passed | Failed |
|---|---|---|---|
| Authentication | 11 | | |
| Navigation | 5 | | |
| Firebase CRUD — reviews | 12 | | |
| Firebase CRUD — restaurants | 6 | | |
| Ownership rules | 4 | | |
| Form validation | 8 | | |
| GPS sensor | 6 | | |
| Layout & theme | 12 | | |
| **Total** | **64** | | |

## Automated tests

14 unit tests in `test/widget_test.dart` cover the model and ratings logic —
reading a Firebase record into a `Restaurant` or `Review`, restaurant
ownership checks, and the `ratingsByRestaurant` averaging function (grouping,
rounding, and the no-reviews case). Run with:

```bash
flutter test
```

## Known limitations

- Distance is straight-line, not driving distance.
- One review per user per restaurant is not enforced; a user can post
  several.
- Adding a restaurant requires a GPS fix; there is no manual latitude/
  longitude entry, so a user who denies location permission cannot add a
  restaurant (they can still browse and review normally).
