/**
 * Scan Translate AI Firestore + Storage Security Rules — Firebase Emulator tests.
 *
 * Covers the required security matrix for the scan_history / users model:
 *   1. Unauthenticated user -> denied everywhere
 *   2. Authenticated user -> another user's data -> denied
 *   3. Authenticated user -> own data -> allowed
 *   4. User A -> write privileged fields (role/admin/permissions) -> denied
 *   5. User A -> forge a scan_history doc with a different userId -> denied
 *   6. User A -> write scan_history with an invalid scanType -> denied
 *   7. scan_history must be queried filtered by userId (list rule) -> denied unfiltered
 *   8. User A -> modify/delete User B's scan_history -> denied
 *   9. Server-issued `role == 'admin'` custom claim -> admin collections allowed
 *  10. Deny-all fallback -> every unmatched path denied
 * plus positive controls proving the app's own write shapes still succeed:
 *   - signUp user doc shape validates
 *   - scan_result save/update/delete path works for the owner
 *   - Storage: owner writes only their own images; public/ is admin-only
 *
 * Run: npm install && npm test
 */
const { test, before, after, beforeEach } = require('node:test');
const assert = require('node:assert/strict');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');

const PROJECT_ID = 'scan-translate-ai-rules-test';

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { host: '127.0.0.1', port: 8080 },
    storage: { host: '127.0.0.1', port: 9199 },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.clearStorage();
});

const anon = () => testEnv.unauthenticatedContext();
const asUserA = (overrides = {}) =>
  testEnv.authenticatedContext('user-A', overrides);
const asUserB = (overrides = {}) =>
  testEnv.authenticatedContext('user-B', overrides);
const asAdmin = () => testEnv.authenticatedContext('admin-user', { role: 'admin' });

// The exact document shapes the Scan Translate AI app writes (mirrors
// auth_remote_datasource.dart / scan_result_model.dart) so we prove the
// rules never reject the app's own creates.
const appUserDoc = (email = 'a@example.com') => ({
  email,
  displayName: 'User A',
  emailVerified: false,
  privacyPolicyAccepted: false,
  createdAt: new Date(),
  lastLoginAt: new Date(),
});

const appScanDoc = (userId, scanType = 'qr', overrides = {}) => ({
  userId,
  scanType,
  formatType: scanType === 'barcode' ? 'code128' : 'qrCode',
  rawValue: 'https://example.com',
  displayValue: 'https://example.com',
  scannedAt: new Date(),
  isFavorite: false,
  ...overrides,
});

// Firestore rule checks -------------------------------------------------------

test('1. Unauthenticated user is denied everywhere', async () => {
  const db = anon().firestore();
  await assertFails(db.doc('users/user-A').get());
  await assertFails(db.doc('scan_history/doc1').get());
  await assertFails(db.collection('scan_history').get());
  await assertFails(db.doc('app_config/general').get());
});

test('2. User A cannot read or write User B data', async () => {
  await asUserB().firestore().doc('scan_history/b-1').set(appScanDoc('user-B'));

  const a = asUserA().firestore();
  await assertFails(a.doc('users/user-B').get());
  await assertFails(a.doc('scan_history/b-1').get());
  await assertFails(a.doc('scan_history/b-2').set(appScanDoc('user-B')));
});

test('3. User A can read and write their own data', async () => {
  const a = asUserA().firestore();
  await assertSucceeds(a.doc('users/user-A').set(appUserDoc()));
  await assertSucceeds(a.doc('scan_history/a-1').set(appScanDoc('user-A')));
  await assertSucceeds(a.doc('users/user-A').get());
  await assertSucceeds(a.doc('scan_history/a-1').get());

  // The app toggles isFavorite via update on its own doc.
  await assertSucceeds(a.doc('scan_history/a-1').update({ isFavorite: true }));
  // The app toggles displayValue on its own doc.
  await assertSucceeds(a.doc('scan_history/a-1').update({ displayValue: 'x' }));
  // The app accepts the privacy policy via update on its own user doc.
  await assertSucceeds(
    a.doc('users/user-A').update({
      privacyPolicyAccepted: true,
      privacyPolicyVersion: '1.0',
      privacyPolicyAcceptedAt: new Date(),
    }),
  );
});

test('4. User A cannot escalate to admin / write privileged fields', async () => {
  const a = asUserA().firestore();
  await assertFails(a.doc('users/user-A').set({ ...appUserDoc(), role: 'admin' }));
  await assertFails(a.doc('users/user-A').update({ role: 'admin' }));
  await assertFails(a.doc('users/user-A').update({ isAdmin: true }));
  await assertFails(a.doc('users/user-A').update({ permissions: ['*'] }));
  await assertFails(a.doc('users/user-A').update({ claims: { admin: true } }));
  await assertFails(a.doc('users/user-A').update({ banned: true }));
  // Privileged fields are also rejected in foreign scan docs.
  await assertFails(
    a.doc('scan_history/a-1').set({ ...appScanDoc('user-A'), role: 'admin' }),
  );
  // Admin-only collections rejected for a normal user.
  await assertFails(a.doc('audit_logs/log1').set({ action: 'x' }));
  await assertFails(a.doc('app_config/general').set({ value: 'x' }));
});

test('5. User A cannot forge scan_history docs for another user', async () => {
  const a = asUserA().firestore();
  await assertFails(a.doc('scan_history/b-forged').set(appScanDoc('user-B')));
  await assertFails(a.doc('scan_history/own').set(appScanDoc('user-B')));
  // Nor tamper the userId of an existing doc.
  await a.doc('scan_history/a-1').set(appScanDoc('user-A'));
  await assertFails(a.doc('scan_history/a-1').update({ userId: 'user-B' }));
  await assertFails(
    a.doc('scan_history/a-1').update({ rawValue: 'x', userId: 'user-B' }),
  );
});

test('6. Invalid scanType documents are rejected', async () => {
  const a = asUserA().firestore();
  await assertFails(a.doc('scan_history/bad-1').set(appScanDoc('user-A', 'evil')));
  await assertFails(
    a.doc('scan_history/bad-2').set(appScanDoc('user-A', 'qr', { scanType: 42 })),
  );
  // Raw value must be a string and the favourite toggle only affects allowed keys.
  await assertFails(a.doc('scan_history/bad-4').set({ ...appScanDoc('user-A'), rawValue: 42 }));
});

test('7. scan_history list queries must be filtered by userId', async () => {
  const a = asUserA().firestore();
  await assertSucceeds(a.collection('scan_history').where('userId', '==', 'user-A').get());
  await assertFails(a.collection('scan_history').get());
  await assertFails(a.collection('scan_history').limit(10).get());
  await assertFails(a.collection('scan_history').where('scanType', '==', 'qr').get());
});

test('8. User A cannot modify or delete User B scan_history', async () => {
  await asUserB().firestore().doc('scan_history/b-1').set(appScanDoc('user-B'));

  const a = asUserA().firestore();
  await assertFails(a.doc('scan_history/b-1').update({ isFavorite: true }));
  await assertFails(a.doc('scan_history/b-1').delete());
});

test('8b. Owner may delete their own scan_history', async () => {
  const a = asUserA().firestore();
  await a.doc('scan_history/a-1').set(appScanDoc('user-A'));
  await assertSucceeds(a.doc('scan_history/a-1').delete());
});

test('9. Positive control: server-issued admin claim is honoured', async () => {
  const adminDb = asAdmin().firestore();
  await assertSucceeds(adminDb.doc('app_config/general').set({ value: 'x' }));
  await assertSucceeds(adminDb.doc('audit_logs/log1').set({ action: 'x' }));
  await assertSucceeds(adminDb.doc('audit_logs/log1').get());
  // Admin may read any user's scan_history and users.
  await asUserB().firestore().doc('scan_history/b-1').set(appScanDoc('user-B'));
  await assertSucceeds(adminDb.doc('scan_history/b-1').get());
  await assertSucceeds(adminDb.doc('users/user-B').get());
});

test('10. Deny-all fallback rejects unmatched paths and collections', async () => {
  const a = asUserA().firestore();
  await assertFails(a.doc('hackers/private').set({ x: 1 }));
  await assertFails(a.doc('favorites/anything').set({ x: 1 }));
  await assertFails(a.doc('favorites/anything').get());
  await assertFails(a.doc('unmatched-deep-path/private').set({ x: 1 }));
  await assertFails(a.doc('users/user-A/subs/favs').set({ x: 1 }));
});

test('10b. User documents may not be deleted by another user', async () => {
  await asUserA().firestore().doc('users/user-A').set(appUserDoc());
  await assertFails(asUserB().firestore().doc('users/user-A').delete());
});

// Storage rule checks ---------------------------------------------------------

test('S1. Unauthenticated user is denied Storage access', async () => {
  const st = anon().storage();
  await assertFails(st.ref('users/user-A/profile/photo.png').getDownloadURL());
});

test('S2. Users are isolated in Storage', async () => {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await ctx.storage().ref('users/user-B/profile/photo.png').putString('me');
    await ctx.storage()
      .ref('scans/user-B/scan.png')
      .putString('scan', undefined, { contentType: 'image/png' });
  });
  const a = asUserA().storage();
  // Scan images are owner/admin-only (read).
  await assertFails(a.ref('scans/user-B/scan.png').getDownloadURL());
  // Writes to another user's profile or scans are denied regardless.
  await assertFails(a.ref('users/user-B/profile/photo.png').putString('x'));
  await assertFails(
    a.ref('scans/user-B/scan.png').putString('x', undefined, { contentType: 'image/png' }),
  );
});

test('S3. Owner may write their own profile/scan images with limits', async () => {
  const a = asUserA().storage();
  const profile = a.ref('users/user-A/profile/photo.png');
  const scan = a.ref('scans/user-A/scan.png');

  await assertSucceeds(
    profile.putString('photo-bytes', undefined, { contentType: 'image/png' }),
  );
  await assertSucceeds(
    scan.putString('scan-bytes', undefined, { contentType: 'image/jpeg' }),
  );
  // Content must be an image and under 5MiB (profile) / 10MiB (scans).
  await assertFails(
    profile.putString('photo-bytes', undefined, { contentType: 'text/plain' }),
  );
  await assertFails(
    scan.putString('scan-bytes', undefined, { contentType: 'application/pdf' }),
  );
  await assertFails(
    profile.putString('x'.repeat(6 * 1024 * 1024), undefined, {
      contentType: 'image/png',
    }),
  );
  await assertFails(
    scan.putString('x'.repeat(11 * 1024 * 1024), undefined, {
      contentType: 'image/png',
    }),
  );
  await assertSucceeds(profile.getDownloadURL());
});

test('S4. Only admin may write public assets (reads are public)', async () => {
  // Seed a public asset through a rules-bypassing context so read checks
  // see an existing object (missing objects error with object-not-found,
  // which would be a false pass for permission checks).
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await ctx.storage()
      .ref('public/banner.png')
      .putString('seeded', undefined, { contentType: 'image/png' });
  });

  const a = asUserA().storage();
  // Writes to public/ are admin-only.
  await assertFails(a.ref('public/banner.png').putString('asset'));
  // Reads are world-readable by design.
  await assertSucceeds(a.ref('public/banner.png').getDownloadURL());
  await assertSucceeds(a.ref('public/banner.png').getMetadata());

  const adminSt = asAdmin().storage();
  await assertSucceeds(
    adminSt.ref('public/banner.png').putString('asset', undefined, {
      contentType: 'image/png',
    }),
  );
});

test('S5. Storage deny-all fallback rejects unmatched paths', async () => {
  const a = asUserA().storage();
  await assertFails(a.ref('admin/secrets.txt').putString('top-secret'));
  await assertFails(a.ref('foo/bar.png').putString('x'));
});
test('L1. Authenticated user can fetch a single lookup doc, never by anon', async () => {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await ctx.firestore().doc('lookups/qr-001').set({ value: 'hello' });
  });
  await assertSucceeds(asUserA().firestore().doc('lookups/qr-001').get());
  await assertFails(anon().firestore().doc('lookups/qr-001').get());
});

test('L2. Lookup collection cannot be enumerated via list', async () => {
  await assertFails(asUserA().firestore().collection('lookups').get());
  await assertFails(asAdmin().firestore().collection('lookups').get());
  await assertFails(anon().firestore().collection('lookups').get());
});

test('L3. Clients cannot create or modify lookup entries', async () => {
  const a = asUserA().firestore();
  await assertFails(a.doc('lookups/qr-002').set({ value: 'x' }));
  await assertFails(a.doc('lookups/qr-001').update({ value: 'y' }));
  await assertFails(a.doc('lookups/qr-001').delete());
  await assertFails(asAdmin().firestore().doc('lookups/qr-003').set({ value: 'z' }));
});
