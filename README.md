# Scan & Translate AI 📷🌐

**On-Device Premium QR/Barcode Scanner, Optical Character Recognition, and Multilingual Translator**

Scan & Translate AI reconfigures the device camera into a universal, privacy-preserving text extraction and translation engine. The application executes QR code and barcode symbology decoding, on-device optical character recognition, and neural machine translation across thirty-five-plus languages—all within the secure confines of the local device, ensuring that no image, document, or transcribed text is ever transmitted to external infrastructure.

## Technical Architecture

### 📷 QR & Barcode Decoding Engine

- **Multisymbology Decoding**: Supports QR codes, UPC/EAN retail point-of-sale barcodes, Code 39 and Code 128 alphanumeric variants, Interleaved Two-of-Five (ITF), Portable Data File 417 (PDF417), Data Matrix anisotropic code structures, and Aztec block-code modalities
- **Instant Decode Visualization**: Real-time decoded content presentation with one-tap copy-to-clipboard and inter-application share actions
- **Mass-Scanning Flow Optimization**: Parallelized frame processing for batch scanning scenarios, with rate-limiting to prevent device thermal throttling

### 🔍 On-Device Optical Character Recognition

- **Document Image Text Extraction**: Robust text recovery from photographic inputs including receipts, identification documents, whiteboard imagery, and screenshot annotations
- **Localized Text Recognition**: Engineered for printed and structured document formats with adaptive perspective correction and contrast normalization
- **Results Screen Presentation**: Dedicated review interface with text selection, copy-action, and inter-application share capabilities

### 🌐 Neural Machine Translation Subsystem

- **Textual Translation Modality**: Source-text input with instant target-language rendering across thirty-five-plus linguistic constituencies
- **Camera-Based Translation**: Live viewfinder text recognition, optical character extraction, and instant translational substitution within the visual field
- **Voice Translation Pipeline**: Real-time speech-to-text transduction, linguistic analysis, and target-language speech synthesis with early-stop heuristics to minimize latency on prolonged utterances
- **Language Repertoire**: English, Spanish, French, German, Italian, Portuguese, Russian, Chinese (Mandarin), Japanese, Korean, Arabic, Hindi, Bengali, Punjabi, Tamil, Telugu, Marathi, Gujarati, Turkish, Dutch, Polish, Thai, Vietnamese, Indonesian, Malay, Persian, Ukrainian, Romanian, Czech, Greek, Swedish, Danish, Norwegian, Finnish, with auto-detection of source language
- **On-Device Model Architecture**: Translation neural network weights downloaded once and cached; subsequent operations execute entirely on-device with zero network egress for translation computation
- **Early-Stop Voice Translation**: Adaptive termination heuristic that ceases transcription upon detected meaningful linguistic content, reducing unnecessary audio capture duration

### 🕒 History & Provenance Tracking

- **Comprehensive Event Logging**: Every scanning, OCR, and translation event persisted to local history database with temporal metadata
- **Searchable Archives**: Full-text search capability across hundred-record archives; filtered search across two-hundred-record archives
- **Export & Clearing Functionality**: User-initiated history evacuation with single-action confirmation

### 👤 Accounts & Authentication Architecture

- **Email/Password Identity Management**: Account creation with email verification token and password recovery flow
- **OAuth2 Google Sign-In**: Federated identity via Google ecosystem credentials
- **Preference Synchronization**: User-configurable scanning preferences and history metadata tied to authenticated identity across application sessions

### 🤫 Privacy & Data Exfiltration Prevention Architecture

- **On-Device Machine Learning Inference**: All Google ML Kit models (text recognition, translation, barcode scanning) execute entirely on the device; zero image or text payload leaves the Trusted Execution Environment
- **Consent-First Advertising Framework**: Google User Messaging Platform (UMP) integration with fail-closed semantics—advertisement rendering is rigorously suppressed until verifiable user consent is recorded; consent withdrawal immediately terminates advertisement pipelines
- **Minimal, Feature-Gated Permissions**: Camera and microphone permissions requested exclusively at the precise moment of feature invocation; application remains fully functional when permissions are denied, with graceful feature degradation and user notification
- **On-Device Model Distribution**: Translation language-pack weights bundled and cached at first launch; subsequent offline operation requires no network connectivity for translation computation

### 📖 User Interaction Protocols

#### 📷 QR Code Scanning Workflow
1. Interface initiation via "Scan QR" or "Scan Barcode" primary action
2. Camera viewfinder activation with real-time symbology detection
3. Instant decoded result presentation with copy, share, and save-to-history actions

### 🔍 OCR Text Extraction Workflow
1. "OCR Text" primary action invocation
2. Photographic input capture (camera) or selection (gallery/picker)
3. Real-time on-device text extraction with live preview
4. Review screen with text selection, copy, share, and history-save actions

### 🌐 Translation Execution Pipeline
1. Modality selection: "Text Translate" (manual entry), "Camera Translate" (live viewfinder), or "Voice Translate" (speech input)
2. Source language specification or auto-detection
3. Target language selection from thirty-five-plus supported linguistic systems
4. Modality-specific execution:
   - **Text**: Instant translation of input string
   - **Camera**: Live viewfinder OCR → translation → visual overlay
   - **Voice**: Real-time speech capture → STT → translation → TTS with early-stop
5. Result presentation with copy, share, and history-save actions

### 🕒 History Navigation & Filtering
1. "History" primary action invocation
2. Chronological list of all scan, OCR, and translation events
3. Text-based search across event metadata
4. Filter controls (date range, modality type)
5. Individual event re-opening or bulk clearing

### 👤 Account Management Workflow
1. "Accounts & Sync" primary action
2. Identity provider selection (email/password or Google)
3. New-account registration with email verification
4. Password recovery flow
5. Preference export/import for cross-device continuity

### 🛡️ Privacy & Data Exfiltration Mitigation Architecture

#### On-Device Machine Learning Inference
All Google ML Kit computational workloads (text recognition, neural machine translation, barcode scanning) execute within the device's native instruction set. No image raster, OCR hypothesis, or translation hypothesis is transmitted to remote servers. The application's threat model assumes a compromised OS but trusted hardware crypto primitives.

#### Consent-First Advertising Architecture
Google User Messaging Platform (UMP) integration implements fail-closed semantics:
- **Consent State Machine**: `unknown` → `required` → `obtained` → `notRequired`
- **Consent State → Advertising Action**:
  - `unknown` or `required`: Advertisement rendering **strictly suppressed**; UI presents consent acquisition interface
  - `obtained`: Advertisement rendering permitted with Google AdMob
  - `notRequired`: Advertisement rendering permitted; consent record preserved for future reference
- **Consent Withdrawal**: User-initiated retraction transitions state to `unknown`, immediately suspending all advertisement pipelines
- **AdMob Data Minimization**: AdMob SDK receives only Advertising ID, approximate geographical location (IP-derived), and non-identifiable interaction metrics; vault, credential, or scan-image data is never forwarded

#### Minimal, Feature-Gated Permission Model
- **Camera**: Invoked exclusively within `MobileScanner` / `image_picker` widget boundaries; app remains fully operational when permission is permanently denied, with explicit user notification that scan/OCR/voice features are unavailable
- **Microphone**: Invoked exclusively within `speech_to_text` widget boundaries; app remains fully operational when permission is permanently denied, with explicit UI indicating voice translation is unavailable
- **Location** (approximate, IP-derived): Provided only to AdMob for advertisement targeting; never accessed by application logic

### 📋 Installation & Deployment Protocol

#### Prerequisites
- Flutter SDK (stable channel, version 3.x as constrained by `pubspec.yaml`)
- Android Studio with Android SDK; `google-services.json` required for custom Firebase builds (prebuilt release APK includes configuration)

#### Android Build Commands
```bash
cd scan-translate-ai
flutter pub get
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### Prebuilt Release Reference
Latest signed release artifacts (APK + AAB): https://github.com/anya12forger12-max/scan-translate-ai/releases

**Note**: Custom Firebase integration requires project-level `google-services.json`; the prebuilt release APK ships with a reference configuration for immediate deployment.

### 📱 Supported Android System Versions
- Android 7.0 (API level 24) and subsequent releases
- Verified builds and testing on Android 14 (API 34) and Android 15 (API 36)

### 🚫 Known Limitations & Constraint Architecture

#### On-Device Model Distribution & Caching
- Translation language-pack weights are downloaded once at first launch and cached in encrypted app-private storage
- Subsequent translation operations execute entirely offline; no network egress for translation computation
- Initial model download requires network connectivity; subsequent launches are fully offline

#### Camera & Microphone Permission Constraints
- Camera and microphone are required for scan, OCR, and voice translation modalities
- Application retains full functionality when these permissions are denied; affected features present explicit, non-technical user notification
- Permanent denial of camera results in disabled QR/barcode scanning and OCR; voice translation becomes unavailable

#### Translation Quality Determinants
- Output fidelity is contingent upon on-device model version, source image/audio capture quality, and linguistic pair complexity
- Auto-detection of source language accuracy varies with script typology and audio clarity

### 📋 Technology Stack Composition

| Layer | Specification |
|-------|-------------|
| **Framework** | Flutter 3.x with Riverpod 2.x reactive provider architecture |
| **State Management** | Riverpod 2.x with notifier pattern |
| **Navigation** | GoRouter 2.x declarative routing |
| **Firebase** | firebase_core, firebase_auth, cloud_firestore, firebase_crashlytics, google_sign_in |
| **Google ML Kit** | text_recognition, translation, barcode_scanning (via mobile_scanner wrapper) |
| **Image Capture** | image_picker, mobile_scanner (transitive dependency) |
| **Speech Input** | speech_to_text |
| **Font Assets** | google_fonts with bundled Poppins and Inter TTF/OTF (zero network fetch for typography) |
| **Advertising** | google_mobile_ads (UMP consent-gated) |
| **Architectural Pattern** | Feature-first: `auth`, `history`, `ocr`, `scanner`, `translation`, `settings` |

### 📜 Privacy Policy & Terms of Reference
- **Privacy Policy**: https://scantranslateai.com/privacy
- **Terms of Service**: https://scantranslateai.com/terms

### 📜 Licensing Instrument
- **License**: Proprietary. All rights reserved.

### 🛠️ Support Channel
- GitHub Issues: https://github.com/anya12forger12-max/scan-translate-ai/issues

---

*Scan & Translate AI: On-device text intelligence without compromise.*

---
*Last edited: [Current Date]*
*Version alignment with `pubspec.yaml` constraint set*