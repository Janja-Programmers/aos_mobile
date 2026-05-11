# AOS Mobile (Africa Online Stores)

Flutter mobile application for Africa Online Stores, a multi-vendor marketplace platform enabling users to buy, sell, post short videos, go live, chat, receive notifications, and make in-app audio/video calls across multiple countries.

---

# 🚀 Installation

Clone the repository:

```bash
git clone $URL_OF_THIS_REPO
cd aos_mobile
```

Install Flutter dependencies:

```bash
flutter pub get
```

---

# ⚙️ System Requirements

Install the required tools:

```text
Flutter SDK
Dart SDK
Android Studio
Xcode
CocoaPods
Git
```

---

## Minimum Recommended Versions

```text
Flutter: 3.x or newer
Dart: 3.x or newer
Android Studio: latest stable
Xcode: latest stable
CocoaPods: latest stable
```

Check your environment:

```bash
flutter doctor
```

Fix any issues shown by Flutter before running the app.

---

# 📱 Supported Platforms

```text
Android
iOS
```

---

# 🔐 Firebase Setup

AOS Mobile uses Firebase for:

- Push notifications
- FCM device tokens
- Android notification delivery
- iOS notification delivery

---

## Android Firebase Setup

Add the Firebase config file:

```text
android/app/google-services.json
```

This file is downloaded from Firebase Console.

⚠️ Do NOT commit production Firebase config files unless your project policy allows it.

---

## iOS Firebase Setup

Add the Firebase config file:

```text
ios/Runner/GoogleService-Info.plist
```

Then install iOS pods:

```bash
cd ios
pod install
cd ..
```

⚠️ Do NOT commit production Firebase config files unless your project policy allows it.

---

# 🔔 Push Notification Setup

The app requires notification permission for push notifications.

## Android

Required permissions are configured in:

```text
android/app/src/main/AndroidManifest.xml
```

Important permissions include:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

For Android 13 and above, notification permission must also be requested at runtime.

---

## iOS

Notification capability must be enabled in Xcode:

```text
Runner → Signing & Capabilities → Push Notifications
Runner → Signing & Capabilities → Background Modes → Remote notifications
```

Also ensure APNs is configured in Firebase Console.

---

# 🎥 Media, Calls & Live Streaming Setup

AOS Mobile uses camera, microphone, and realtime media permissions for:

- Audio calls
- Video calls
- Go Live streaming
- Short video uploads
- Image uploads
- Product media

---

## Android Permissions

Configured in:

```text
android/app/src/main/AndroidManifest.xml
```

Common permissions:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
```

For older Android versions:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

---

## iOS Permissions

Configured in:

```text
ios/Runner/Info.plist
```

Common permission descriptions:

```xml
<key>NSCameraUsageDescription</key>
<string>AOS needs camera access for product images, video calls, and live streaming.</string>

<key>NSMicrophoneUsageDescription</key>
<string>AOS needs microphone access for calls and live streaming.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>AOS needs photo library access to upload product images and videos.</string>
```

---

# 🌐 Backend Configuration

The mobile app connects to the AOS backend powered by Frappe.

Update the API base URL inside the app configuration.

Example:

```text
https://your-domain.com
```

For local development, use the correct reachable backend URL:

```text
http://localhost:8000
```

On Android emulator:

```text
http://10.0.2.2:8000
```

On a physical device, use your machine LAN IP:

```text
http://192.168.x.x:8000
```

---

# ▶️ Running the App

Run on a connected device or emulator:

```bash
flutter run
```

Run in release mode:

```bash
flutter run --release
```

Run for a specific device:

```bash
flutter devices
flutter run -d DEVICE_ID
```

---

# 🤖 Android Build

Build APK:

```bash
flutter build apk --release
```

Build Android App Bundle for Play Store:

```bash
flutter build appbundle --release
```

Output location:

```text
build/app/outputs/
```

---

# 🍎 iOS Build

Install pods:

```bash
cd ios
pod install
cd ..
```

Build iOS:

```bash
flutter build ios --release
```

Open in Xcode:

```bash
open ios/Runner.xcworkspace
```

Use Xcode to archive and upload to App Store Connect.

---

# 🧪 Testing

Run all tests:

```bash
flutter test
```

Run analyzer:

```bash
flutter analyze
```

Format code:

```bash
dart format .
```

---

# 📁 Project Structure

```text
aos_mobile/
├── android/                 # Android native project
├── ios/                     # iOS native project
├── lib/                     # Main Flutter application code
│   ├── core/                # Shared app infrastructure
│   ├── features/            # Feature-based modules
│   ├── main.dart            # App entry point
│   └── bootstrap.dart       # App bootstrap/config setup
├── assets/                  # Images, icons, fonts, static assets
├── test/                    # Flutter tests
├── pubspec.yaml             # Flutter dependencies and assets
└── README.md
```

---

# 🧱 Architecture

AOS Mobile follows a feature-first Flutter architecture.

Typical feature structure:

```text
features/
└── feature_name/
    ├── application/         # State managers, controllers, use-case orchestration
    ├── data/                # API clients, DTOs, mappers
    ├── domain/              # Entities, value objects, enums
    ├── presentation/        # Screens, widgets, UI components
    └── repository/          # Repository contracts/implementations
```

Core principles:

- Feature-first structure
- Riverpod for state management
- State-driven navigation
- Clean separation of data, domain, application, and UI
- Backend APIs isolated from presentation layer
- Reusable shared services under `core/`

---

# 🔄 Realtime Features

AOS Mobile uses realtime communication for:

- Chat updates
- Incoming calls
- Call accepted/rejected/ended events
- Live stream started/ended events
- Live viewer count updates
- Notifications

Realtime logic should remain centralized in shared/core services and feature-specific listeners.

UI should react to state changes instead of directly handling raw socket events.

---

# 📞 Calls

The app supports in-app audio/video calls.

Call flow depends on:

- Backend call APIs
- Realtime call events
- LiveKit room tokens
- Microphone/camera permissions
- Call state manager
- Call navigation listener

Important call states include:

```text
initiated
ringing
ongoing
ended
missed
rejected
failed
canceled
```

---

# 📡 Go Live

The app supports seller live streaming using LiveKit.

Live flow depends on:

- Backend live APIs
- LiveKit token generation
- Frappe realtime room events
- Viewer tracking
- Viewer count updates
- Host/viewer role state

---

# 🎬 Shorts

The app supports short product videos.

Shorts features include:

- Feed playback
- Seller marketing videos
- Short details
- Likes
- Comments
- Shares
- Product/ad linking
- Video controller caching
- Scroll-based pagination

---

# 🔐 Security Notes

- Do NOT commit secrets
- Do NOT commit private signing keys
- Do NOT commit production `.env` files
- Do NOT commit upload keystores
- Do NOT commit Firebase service account JSON files
- Keep API keys and credentials outside source control
- Use release signing only for production builds

---

# 🔑 Android Signing Notes

Release builds require a signing key.

Common files:

```text
android/key.properties
android/app/upload-keystore.jks
```

These should not be committed.

Example ignored files:

```gitignore
android/key.properties
android/app/*.jks
android/app/*.keystore
```

Build release bundle:

```bash
flutter build appbundle --release
```

---

# 🍎 iOS Signing Notes

iOS release builds require:

- Apple Developer account
- Bundle identifier
- Signing certificate
- Provisioning profile
- Push notification capability
- App Store Connect setup

Use Xcode for archive and upload.

---

# 🧠 Production Notes

Before production release:

- Confirm backend base URL points to production
- Confirm Firebase project is production-ready
- Confirm Android signing uses the correct upload key
- Confirm iOS signing and capabilities are correct
- Test push notifications
- Test login/session persistence
- Test calls
- Test live streaming
- Test shorts playback
- Test upload flows
- Test poor network/offline states
- Run `flutter analyze`
- Run `flutter test`
- Build release APK/AAB/IPA

---

# 🧹 Common Commands

Clean project:

```bash
flutter clean
flutter pub get
```

Repair iOS pods:

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

Run code generation if used:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

# 🤝 Contributing

Install dependencies:

```bash
flutter pub get
```

Before committing:

```bash
dart format .
flutter analyze
flutter test
```

Recommended commit style:

```text
feat(feature): add new capability
fix(feature): resolve issue
refactor(feature): improve structure
chore(project): update tooling/config
```

---

# 🔄 CI

Recommended CI checks:

- Install Flutter
- Run `flutter pub get`
- Run `dart format --set-exit-if-changed .`
- Run `flutter analyze`
- Run `flutter test`
- Build Android release artifact

---

# 📄 License

MIT
