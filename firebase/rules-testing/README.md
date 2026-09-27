# Scan Translate AI Firebase Security Rules Tests

Runs the Firestore + Storage security rules against the **Firebase
Emulator**, proving the authorization model before any release:

| #  | Case | Expected |
|----|------|----------|
| 1  | Unauthenticated user | denied everywhere |
| 2  | User A -> User B data | denied |
| 3  | User A -> own data | allowed (incl. app's exact write shapes) |
| 4  | User A -> write privileged fields (role/admin/permissions/claims/banned) | denied |
| 5  | User A -> forge scan_history doc for another user | denied |
| 6  | scan_history with invalid scanType / non-string fields | denied |
| 7  | scan_history list without a userId filter | denied |
| 8  | User A -> modify/delete User B scan_history | denied |
| 8b | Owner -> delete own scan_history | allowed |
| 9  | Server-issued `role == 'admin'` custom claim | allowed (positive control) |
| 10 | Deny-all fallback on unmatched paths | denied |
| 10b | User B -> delete User A's user doc | denied |
| S1 | Unauthenticated Storage access | denied |
| S2 | Cross-user Storage reads/writes | denied |
| S3 | Owner writes own images within size/type limits | allowed (limits enforced) |
| S4 | public/ writes | admin-only (reads public) |
| S5 | Storage deny-all fallback | denied |

## Why this model

- Admin authorization is granted **only** via Firebase Authentication custom
  claims (`request.auth.token.role == 'admin'`), which the client cannot write.
- The `role`/`isAdmin`/`admin`/`permissions`/`claims`/`banned` fields are
  **rejected by the rules** for any client write, so a normal user can never
  escalate.
- `scan_history` documents are owner-scoped: reads/writes/updates/deletes all
  require `userId == request.auth.uid`, and **list queries must carry a
  `userId` filter** (enforced by the `allow list` rule) so a user can never
  enumerate other users' scans.
- Storage follows the same model: only the owner may write their own
  `users/{uid}/profile/` and `scans/{uid}/` paths (with size + content-type
  limits), and `public/` is admin-write, world-read.

## Running

```bash
cd firebase/rules-testing
npm install
npm test
```

`npm test` starts the emulators (`firestore` + `storage`) via
`firebase emulators:exec` and runs the suite against them.

## Notes

- The suite targets the emulators only; no real Firebase project data is
  touched. A dummy `GCLOUD_PROJECT` is used for the test environment.
- Storage rules cannot currently be live-deployed (the project has no Storage
  bucket) but are kept hardened and exercised by the emulator.