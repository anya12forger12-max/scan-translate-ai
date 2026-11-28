# Scan & Translate AI

A Flutter camera toolkit that decodes barcodes, reads text with on-device ML Kit, and translates in app — with signed-in history backed by Firebase.

`scan_translate_ai` (version 1.2.33+38) includes Android, iOS, web, macOS, Linux, and Windows runners. Barcode decoding uses `mobile_scanner`, OCR uses `google_mlkit_text_recognition`, and translation uses `google_mlkit_translation` models that run on the device after a one-time download. Accounts and scan history use Firebase Authentication and Cloud Firestore.

## What it does

### Barcode and QR scanning

- Separate QR and barcode scanner pages with a live `mobile_scanner` viewfinder.
- Format mapping covers QR, UPC-A, UPC-E, EAN-8, EAN-13, Code 39, Code 93, Code 128, Codabar, ITF, PDF417, Data Matrix, Aztec, GS1, ISBN, and ISSN; decipherable formats depend on the platform scanner.
- Result pages show the decoded value with copy and share actions, and can save it to the signed-in user's history.

### Text recognition (OCR)

- Capture with the camera or pick an image from the gallery via `image_picker`.
- Recognize printed text locally with ML Kit's `TextRecognizer`.
- Review the extracted text on a result page with copy and share actions.

### Translation

- Three input modes: typed text, a photographed image (OCR followed by translation), and speech input.
- Translation runs through ML Kit's `OnDeviceTranslator`; source and target language packs are downloaded on demand and cached by the SDK. Availability of a pair depends on the installed models.
- Voice mode uses `speech_to_text` for input and `flutter_tts` to speak the result; it stops listening once a final transcript arrives or after a timeout.
- The selector offers 34 named languages plus `Auto`. `Auto` uses a small script-based heuristic (Latin/CJK/Cyrillic/Arabic/Devanagari, otherwise English), not a learned language detector.
- Results can be copied, shared, and stored in history.

### Accounts and history

- Email/password registration, email verification, password reset, and Google sign-in.
- A mandatory privacy-policy acceptance gate before the home screen.
- Per-user scan history in Cloud Firestore, ordered by time, filterable by scan type, searchable, with favorites, individual deletion, and bulk clear. A signed-in account is required.

### Ads, fonts, and diagnostics

- An AdMob banner on the home screen is gated by Google UMP consent; the service fails closed on Android/iOS until a definitive allow state is reached.
- Poppins and Inter fonts are bundled in `assets/fonts` and runtime fetching is disabled, so typography works offline.
- Firebase Crashlytics is wired at startup when Firebase initializes successfully; failures are logged without crashing the app.

## Quick start

Requirements: a Flutter SDK matching `sdk: ^3.12.2` in [`pubspec.yaml`](pubspec.yaml), plus Android Studio/Xcode for device builds.

```bash
git clone https://github.com/anya12forger12-max/scan-translate-ai.git
cd scan-translate-ai

flutter pub get
flutter run

# Checks and release artifacts
flutter test
flutter analyze
flutter build apk --release
flutter build appbundle --release
flutter build web --release
```

The repo includes native Firebase configuration files and [`firebase.json`](firebase.json), [`firestore.rules`](firestore.rules), [`storage.rules`](storage.rules), and [`firestore.indexes.json`](firestore.indexes.json). Point them at your own Firebase project (Authentication, Firestore, and Crashlytics) for custom builds; the checked-in files are not a substitute for your own project setup. Emulator security tests live in [`firebase/rules-testing`](firebase/rules-testing):

```bash
cd firebase/rules-testing
npm install
npm test
```

Web deployment uses [`vercel.json`](vercel.json) and [`scripts/vercel-build.sh`](scripts/vercel-build.sh), which install a pinned Flutter version when one is not already available. Release artifacts, if published, are listed on the [GitHub Releases page](https://github.com/anya12forger12-max/scan-translate-ai/releases).

## Project structure

```text
lib/
├── main.dart                 # Firebase + Crashlytics bootstrap
├── app/                      # app shell, routing, dependency providers
├── core/                     # theme, constants, errors, network, widgets
├── features/
│   ├── auth/                 # login, registration, verification, recovery
│   ├── scanner/              # QR/barcode pages and result handling
│   ├── ocr/                  # camera/gallery capture and text recognition
│   ├── translation/          # text, camera, and voice translation
│   ├── history/              # Firestore-backed history and filters
│   ├── settings/             # preferences
│   └── privacy_policy/       # mandatory acceptance screen
├── services/                 # UMP consent service
└── widgets/                  # consent-gated ad banner
android/ ios/ web/ linux/ macos/ windows/   # platform runners
test/                          # widget and unit tests
```

## Data and privacy

Recognition and translation inference happen on the device, and fonts are bundled. That does **not** mean the app is fully offline: account data and scan/OCR/translation history are stored in Firebase, crash diagnostics go to Crashlytics, and ads may be requested after consent. Read [PRIVACY.md](PRIVACY.md), [PRIVACY_POLICY.md](PRIVACY_POLICY.md), and [TERMS_AND_CONDITIONS.md](TERMS_AND_CONDITIONS.md) before deploying or using the app with real data.

Support: [SECURITY.md](SECURITY.md), [CONTRIBUTING.md](CONTRIBUTING.md), [TROUBLESHOOTING.md](TROUBLESHOOTING.md), and [GitHub Issues](https://github.com/anya12forger12-max/scan-translate-ai/issues).

## License

MIT License, Copyright (c) 2026 Scan_Translate_Ai — see [`LICENSE`](LICENSE).
