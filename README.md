# UniBazzar

UniBazzar is a Flutter + Firebase app organized by feature modules (auth, listings, payments, profile, admin) with Riverpod for state management and a dark-first Material theme.

## Tech Stack

- Flutter 3.10+ / Dart 3.10
- Riverpod for state management
- Firebase Core, Auth, Firestore, Google Sign-In
- HTTP client, Google Fonts, Material theming

## Project Structure

- lib/main.dart: bootstraps Firebase, wraps the app in ProviderScope, and configures routing/theme
- lib/core: cross-cutting pieces such as dependency injection, routing, services, theme, shared widgets
- lib/features: feature folders (auth, listing, payment, profile, admin, splash)
- assets/icon: app icon source used by flutter_launcher_icons

## Prerequisites

- Flutter SDK (>=3.10.3) with platform toolchains (Android Studio/SDK for Android, Xcode for iOS)
- Firebase project with platform configs:
  - android/app/google-services.json
  - ios/Runner/GoogleService-Info.plist
- (Optional) Firebase CLI if you need to regenerate lib/firebase_options.dart via flutterfire configure

## Setup

1. Install dependencies: `flutter pub get`
2. Place Firebase config files in the paths above
3. (Optional) Regenerate app icons after updates: `flutter pub run flutter_launcher_icons`

## Running

- Start an emulator/simulator or connect a device, then `flutter run`
- For web: `flutter run -d chrome`

## Quality

- Static analysis: `flutter analyze`
- Tests: `flutter test`
