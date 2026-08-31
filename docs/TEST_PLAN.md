# Test Plan — Colombo Eats

Manual testing carried out on an Android emulator (Pixel 6, API 34) and
recorded below. Fill the Result and Date columns in as you run each case, and
paste the completed table into the submission document.

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

| ID | Test case | Steps | Expected result | Result | Date |
|---|---|---|---|---|---|
| A1 | Register with valid details | Register → fill all fields → Create account | Account created, app opens on Home tab | | |
| A2 | Register with invalid email | Enter `nethusha.com` → submit | Field error "Enter a valid email address"; nothing sent to Firebase | | |
| A3 | Register with short password | Enter `123` → submit | Field error "Password must be at least 6 characters" | | |
| A4 | Passwords do not match | Enter different confirm password | Field error "Passwords do not match" | | |
| A5 | Register with existing email | Use an email already registered | Red bar: "An account already exists with that email" | | |
| A6 | Sign in with correct details | Enter valid credentials → Sign in | Opens on Home tab | | |
| A7 | Sign in with wrong password | Enter valid email, wrong password | Red bar: "Email or password is incorrect" | | |
| A8 | Sign in with empty fields | Tap Sign in with both blank | Both fields show validation errors | | |
| A9 | Session persists | Sign in → close app → reopen | Opens signed in, no login screen | | |
| A10 | Sign out | Profile → Sign out → confirm | Returns to login screen | | |
| A11 | Cancel sign out | Profile → Sign out → Cancel | Stays signed in | | |

## 2. Navigation

| ID | Test case | Steps | Expected result | Result | Date |
|---|---|---|---|---|---|
| N1 | All four tabs reachable | Tap each destination in the bottom bar | Correct screen shown, icon fills in | | |
| N2 | Master/detail | Restaurants → tap any card | Detail screen opens with that restaurant | | |
| N3 | Back from detail | Detail → back arrow | Returns to the list, scroll position kept | | |
| N4 | Login links to register | Login → Register | Register screen opens | | |
| N5 | Register back | Register → back arrow | Returns to login | | |

## 3. Firebase CRUD

| ID | Test case | Steps | Expected result | Result | Date |
|---|---|---|---|---|---|
| C1 | **Read** restaurants | Open Restaurants tab | 8 restaurants load from Firebase | | |
| C2 | **Create** a review | Detail → Write a review → fill → Post | Snackbar "Review posted"; appears under Reviews immediately | | |
| C3 | Created review is mine | My Reviews tab | The new review is listed | | |
| C4 | **Update** a review | My Reviews → edit icon → change rating → Save changes | Snackbar "Review updated"; new values shown | | |
| C5 | **Delete** a review | My Reviews → delete icon → Delete | Snackbar "Review deleted"; row disappears | | |
| C6 | Cancel delete | Delete icon → Cancel | Review is not deleted | | |
| C7 | Live sync | Add a review in the Firebase console while the app is open | Appears in the app without any refresh | | |
| C8 | Only my reviews are editable | Sign in as a second user, view a restaurant | Other users' reviews visible but no edit/delete buttons on My Reviews | | |
| C9 | Loading state | Open Restaurants on a cold start | Spinner shown before the list appears | | |
| C10 | Error state | Turn off emulator network → open Restaurants | "Could not load restaurants" message, no crash | | |
| C11 | Empty state | Set the rating filter to 5.0 | "No restaurants match" message | | |
| C12 | Rules block bad writes | Firebase console → Rules → Simulator → write to `/reviews` unauthenticated | Simulation denied | | |

## 4. Form validation

| ID | Test case | Steps | Expected result | Result | Date |
|---|---|---|---|---|---|
| F1 | Empty comment | Post review with blank comment | "Write a few words about your visit" | | |
| F2 | Comment too short | Enter `Good` | "Please write at least 10 characters" | | |
| F3 | Rating slider | Drag from 1.0 to 5.0 | Value updates live next to the slider | | |
| F4 | Meal dropdown | Open dropdown, choose Lunch | Selection shown in the field | | |
| F5 | Date picker | Tap the date field, choose a past date | Date shown as e.g. "12 Aug 2026" | | |
| F6 | Future date blocked | Open the date picker | Dates after today cannot be selected | | |
| F7 | Comment length cap | Type past 400 characters | Counter stops at 400 | | |
| F8 | Edit pre-fills | My Reviews → edit | Rating, meal and comment already filled in | | |

## 5. Hardware sensor — GPS

| ID | Test case | Steps | Expected result | Result | Date |
|---|---|---|---|---|---|
| G1 | Permission requested | First tap of the ➤ icon | Android permission dialog appears | | |
| G2 | Permission allowed | Allow | Distance badges appear; list sorts nearest first | | |
| G3 | Permission denied | Deny | Red bar explaining distances will not show; **no crash** | | |
| G4 | Location services off | Emulator settings → Location off → tap ➤ | Message "Location is switched off on this device" | | |
| G5 | Distances are plausible | Set emulator to 6.9271, 79.8612 | Colombo 01–07 restaurants all within a few km | | |
| G6 | Dismiss the bar | Tap × on the location bar | Bar closes, distances stay | | |

## 6. Layout, theme and animation

| ID | Test case | Steps | Expected result | Result | Date |
|---|---|---|---|---|---|
| L1 | Dark mode | Device Settings → Display → Dark theme | App recolours with no restart | | |
| L2 | Light mode | Turn dark theme back off | App returns to light palette | | |
| L3 | Portrait phone | Restaurants tab, upright | Single-column list of wide cards | | |
| L4 | Landscape phone | Rotate | Two-column grid of compact cards | | |
| L5 | Tablet portrait | Run on a Pixel Tablet AVD | Two-column grid | | |
| L6 | Tablet landscape | Rotate the tablet | Three-column grid | | |
| L7 | Detail portrait | Open a restaurant upright | Photo on top, details underneath | | |
| L8 | Detail landscape | Rotate | Photo on the left, details scroll on the right | | |
| L9 | Hero animation | Tap a card | Photo expands from the card into the detail screen | | |
| L10 | Filter animation | Tap the filter icon | Panel slides open rather than snapping | | |
| L11 | Image fallback | Break an imageUrl in Firebase | Grey box with a fork icon, no red error box | | |
| L12 | Long name | Set a restaurant name to 60 characters | Name truncates with "…", layout does not break | | |

---

## Summary

| Section | Cases | Passed | Failed |
|---|---|---|---|
| Authentication | 11 | | |
| Navigation | 5 | | |
| Firebase CRUD | 12 | | |
| Form validation | 8 | | |
| GPS sensor | 6 | | |
| Layout & theme | 12 | | |
| **Total** | **54** | | |

## Automated tests

Five unit tests in `test/widget_test.dart` cover the model conversion logic —
reading a Firebase record into a `Restaurant`, handling missing and
whole-number fields, and a `Review` round trip. Run with:

```bash
flutter test
```

## Known limitations

- Restaurants are reference data loaded by console import; the app does not
  create or edit them. All four CRUD operations are demonstrated on reviews.
- Distance is straight-line, not driving distance.
- One review per user per restaurant is not enforced; a user can post several.
