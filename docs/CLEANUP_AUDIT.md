# Behavior-preserving cleanup

Baseline: `a64d19d`. Scope: application Dart code and tests. Package internals,
generated configuration, Firebase rules, dependencies and existing untracked
files were left unchanged. Existing public signatures, return types, validation
messages and exception handling were retained.

## Pattern audit

| Pattern | Outcome |
|---|---|
| 1. Duplicate helpers | Moved identical login/register email validation into `lib/utils/form_validators.dart`. No existing validation utility was present. Password validators retain their distinct required-field messages. |
| 2. `_v2`, `_new`, `_impl` clones | None found in application code. |
| 3. Standard-library reinventions | Replaced manual filtering with `where`/`any` and rating summation with `fold`. Kept the date formatter because its exact English output is stored in the database. |
| 4. Single-implementation abstract classes or registries | None found. |
| 5. Dead private helpers or unused parameters | None identified by call-site inspection and analysis. Public `isUserAdded` remains, including its existing tests. |
| 6. Speculative future functionality | No removable private scaffolding identified. Public model fields remain even where the UI does not currently use them. |
| 7. Pass-through wrappers | Public auth/database service methods remain to preserve the API and asynchronous error behavior. Private navigation helpers construct routes rather than merely forwarding arguments. |
| 8. Broad exception swallowing | Existing catches show error messages and restore loading state. Narrowing them would change error behavior, so they remain. No silent catch-and-return-null helper was found. |
| 9. Reflection/interface probing | No reflection chains found. Dynamic maps at the Firebase serialization boundary remain. |
| 10. Redundant revalidation | UI validation and database rules serve different boundaries; retained both. |
| 11. Redundant null checks | No safe removal identified for newly created non-null locals. Authentication, stream, GPS and legacy-record fallbacks remain. |
| 12. Narrating comments | Removed syntax and widget narration. Kept brief explanations of non-obvious behavior. |
| 13. Bloated documentation comments | Shortened 35 blocks to describe contracts and constraints. |
| 14. Identifier density | Existing local names are generally concise. Used contextual collection callback names; avoided cosmetic renaming of public APIs. |
| 15. Decorative section banners | Removed database service banners. |
| 16. Unused imports | Analyzer reported none. No dependencies were removed. |

## Verification

- Baseline suite: 14 passing tests, run before source edits.
- Final suite: 17 passing tests. Three new validator tests preserve required-field
  messages, supported addresses and existing restrictions.
- Full suite run after each atomic edit, including comment and formatting edits.
- `flutter analyze --no-pub`: no issues.
- Dart formatting check: 24 application/test files, no changes required.
- Comment-only changes were also checked for unchanged executable tokens.

| Measured file | Before | After |
|---|---:|---:|
| `models/restaurant.dart` | 16/29 | 16/29 |
| `models/review.dart` | 19/19 | 19/19 |
| `utils/ratings.dart` | 11/11 | 10/10 |
| `utils/form_validators.dart` | Not present | 4/4 |
| Total covered executable lines | 46/59 (78.0%) | 49/62 (79.0%) |

The ratings denominator decreased after replacing the summation loop. No
measured file lost coverage percentage. These totals cover only files exercised
by the tests, not the entire application. UI, GPS, authentication and deployed
Firebase rules were not runtime-tested in this cleanup.

## Commit boundaries

- `9192368`: duplicate email validation.
- `c8d6a54`: native collection operations.
- `7eddb10`: narrative comments.
- `680c82e`: documentation comments.
- `c9b59ee`: decorative banners.
- `657f5ee`: formatting only.

Existing review-date behavior, deletion messaging, ranking labels and rule gaps
remain outside this behavior-preserving change. Fixing them requires a separate
behavior-change task.
