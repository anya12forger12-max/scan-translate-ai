# Scan & Translate AI 📷🌐

**Premium QR/Barcode Scanner, OCR, and Translator — all on device**

Scan & Translate AI turns your camera into a universal text tool. Scan QR codes and barcodes, extract text from any photo with OCR, and translate text, images, or your voice into **35+ languages** — all processed on your device with Google ML Kit, so it works offline and your photos never leave your phone.

## Features

### 📷 QR & Barcode Scanner
- Scan QR codes, UPC/EAN retail barcodes, Code 39/128, ITF, PDF417, Data Matrix, and Aztec codes
- Instantly view decoded content with copy & share actions
- Dedicated mass-scanning flows optimized for speed

### 🔍 OCR Text Recognition
- Pull text out of photos, receipts, documents, and screenshots
- On-device text recognition — private and instant
- Review recognized text on a dedicated results screen, copy or share it

### 🌍 Translation (35+ languages)
- **Text Translate** — type or paste text and translate instantly
- **Camera Translate** — point at a foreign sign or menu, recognize the text, and translate it in one step
- **Voice Translate** — speak naturally; your speech is transcribed and translated (with early-stop so it doesn't wait on long pauses)
- Supported languages: English, Spanish, French, German, Italian, Portuguese, Russian, Chinese, Japanese, Korean, Arabic, Hindi, Bengali, Punjabi, Tamil, Telugu, Marathi, Gujarati, Turkish, Dutch, Polish, Thai, Vietnamese, Indonesian, Malay, Persian, Ukrainian, Romanian, Czech, Greek, Swedish, Danish, Norwegian, Finnish + auto-detect
- **On-device model downloads** — translation models are downloaded once, then cached, so subsequent translations work offline

### 🕘 History
- Every scan, OCR, and translation saved to your history
- Searchable and filterable (list loads up to 100, search up to 200)
- Clear history anytime from Settings

### 👤 Accounts & Sync
- Email/password sign-up with verification and password recovery
- Google Sign-In support
- Preferences and history tied to your account across sessions

### 🤫 Privacy
- **On-device ML** for scanning, OCR, and translation — your images and text are processed locally, not uploaded
- Consent-first advertising (Google UMP, fail-closed): ads are never shown before you consent
- Minimal permissions, requested only when the feature needs them

## How to Use

1. **Scan** — tap **Scan QR** or **Scan Barcode**, point your camera, and the result appears instantly. Copy, share, or save it to history.
2. **Read text from an image** — tap **OCR Text**, capture or pick a photo, and review the recognized text.
3. **Translate** — pick **Text Translate** (type/paste), **Camera Translate** (photo), or **Voice Translate** (speak). Choose source/target languages or leave source on **Auto**.
4. **Find it later** — open **History** to search and reopen any past scan or translation.
5. **First translation** downloads the language models once (a short wait); after that, translations are quick and offline.

## Use Cases

- Translating menus, signs, receipts, and product labels while traveling
- Extracting copy-pasteable text from photos, slides, and scanned documents
- Checking a barcode or QR code before you scan it into another app
- Communicating across languages by voice while offline

## Installation

### Prerequisites
- Flutter 3.x (see `pubspec.yaml` for exact SDK constraints)
- Android Studio / Android SDK for Android builds

### Android (APK)
```bash
cd scan-translate-ai
flutter pub get
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android (App Bundle)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

Latest signed prebuilt release (APK + AAB): see the [Releases](https://github.com/anya12forger12-max/scan-translate-ai/releases) page.

> **Note:** Firebase integration (Auth, Firestore, ML Kit) requires your own `google-services.json` for custom builds; the prebuilt release APK already includes it.

## Supported Android Versions

- Android 7.0 (API 24) and later.
- Built and tested on Android 14 (API 34) / Android 15 (API 36).

## Known Limitations

- On-device translation models are downloaded and cached on the device; downloading them (and cloud features) requires a network connection.
- Camera and microphone access are required for the scan and voice features; the app stays usable when these are denied, and the affected features indicate the denied permission.
- Translation quality depends on the on-device model and the source image/audio quality.

## Technology Stack

- **Flutter / Dart** with **Riverpod** (state) and GoRouter (navigation)
- **firebase_core / firebase_auth / cloud_firestore / firebase_analytics / firebase_crashlytics / firebase_messaging** and **google_sign_in**
- **Google ML Kit**: `barcode_scanning`, `text_recognition`, `translation` — all on-device
- **camera / image_picker / mobile_scanner** for capture and scanning
- **speech_to_text** for voice translation
- Feature-first architecture: `auth`, `history`, `ocr`, `scanner`, `translation`, `settings`

## Privacy Policy & Terms

- Privacy Policy: https://scantranslateai.com/privacy
- Terms: https://scantranslateai.com/terms

## License

Proprietary. All rights reserved.

## Support

Report issues via the [GitHub Issues](https://github.com/anya12forger12-max/scan-translate-ai/issues) tab.