# References needed for Colombo_Eats_Report.docx

Seven inline markers were placed in the report. None of these have been
verified against a real source; I did not invent URLs, authors or access
dates. For each one, find the actual source, then send it back in Harvard
format so it can be inserted into section 11 (References) and the marker
in the body text can be replaced with the proper in-text citation.

---

### REF-01
**Sentence it sits in** (Section 2, Development Approach and Architecture):
"I chose Flutter because it compiles one Dart codebase to a native Android
binary (REF-01), which meant I did not need a second language or a
separate build system for the coursework."
**Source needed:** official Flutter documentation describing the
compile-to-native-ARM/architecture model (not a blog post or tutorial).
**Suggested search term:** `flutter architectural overview compiled native ARM code site:docs.flutter.dev`

### REF-02
**Sentence it sits in** (Section 4, Interface Design and Accessibility):
"The whole app uses Material 3 and generates both colour schemes from one
seed colour, a deep orange, 0xFFBF360C, with ColorScheme.fromSeed (REF-02)."
**Source needed:** Material Design 3 documentation on dynamic colour /
colour schemes generated from a single seed colour, or the Flutter API
documentation for ColorScheme.fromSeed.
**Suggested search term:** `material design 3 dynamic color from seed` OR
`Flutter ColorScheme.fromSeed API documentation`

### REF-03
**Sentence it sits in** (Section 4, Interface Design and Accessibility):
"I did not want to assume the seed colour produced readable text, so I
wrote a script using the same ColorScheme.fromSeed call the app uses and
measured the WCAG contrast ratio (REF-03) for eight foreground and
background pairs, in both light and dark mode."
**Source needed:** WCAG 2.1 (or 2.2) success criterion 1.4.3 (Contrast
Minimum), the actual W3C specification page, for the 4.5:1 and 3:1
thresholds used.
**Suggested search term:** `WCAG 2.1 success criterion 1.4.3 contrast minimum W3C`

### REF-04
**Sentence it sits in** (Section 6, Firebase Realtime Database):
"The deployed rules (REF-04, Appendix B) refuse every read and write by
default, then open both nodes to read for a signed-in user only."
**Source needed:** Firebase Realtime Database Security Rules
documentation (the official Firebase/Google docs explaining rule syntax
and default-deny behaviour).
**Suggested search term:** `Firebase Realtime Database security rules documentation understand rules`

### REF-05
**Sentence it sits in** (Section 6, Firebase Realtime Database):
"I used the Realtime Database rather than Firestore because it was what
the coursework covered, and I read every list through an .onValue stream
(REF-05) rather than a one-off .get()."
**Source needed:** Firebase documentation on reading data / the onValue
event listener for the Realtime Database (Flutter/Dart SDK specifically,
if possible).
**Suggested search term:** `Firebase Realtime Database Flutter onValue read data documentation`

### REF-06
**Sentence it sits in** (Section 7, Location Services):
"Android's fused location provider was returning a cached fix it judged
recent enough (REF-06)."
**Source needed:** either the geolocator package documentation (pub.dev)
explaining forceLocationManager and the fused location provider's caching
behaviour, or Android's own documentation on FusedLocationProviderClient.
**Suggested search term:** `geolocator pub.dev forceLocationManager AndroidSettings` OR
`Android FusedLocationProviderClient getCurrentLocation cached location behaviour`

### REF-07
**Sentence it sits in** (Section 7, Location Services):
"LocationService.currentPosition() checks three states before reading
anything: whether location is switched on, whether permission has been
granted, asking once if not, and whether permission has been permanently
denied, which needs a message pointing the user to Android's own Settings
since the system dialog will not appear again (REF-07)."
**Source needed:** Android developer documentation on runtime permissions,
specifically the "don't ask again" / permanently-denied behaviour
(shouldShowRequestPermissionRationale returning false).
**Suggested search term:** `Android request runtime permissions documentation shouldShowRequestPermissionRationale denied permanently`

---

Once real sources are found, format each as a standard Harvard reference
(Author/Organisation, Year, Title, Available at: URL, Accessed: date) and
send them back. They will replace the placeholder note currently in
section 11 of the report, and each (REF-0N) marker in the body text should
be swapped for the matching Harvard in-text citation, e.g. (Google, 2024).
