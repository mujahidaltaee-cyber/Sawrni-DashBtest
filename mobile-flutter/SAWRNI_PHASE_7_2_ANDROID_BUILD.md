# Sawrni Phase 7.2 — Mobile Visual Identity + Android Build Preparation

Brand slogan:

استوديو كامل بجيبك

## What this phase adds

- Sawrni Arabic-first mobile UI foundation
- Purple/gold/navy brand theme
- Splash screen with slogan
- Customer/provider role choice
- Phone login and OTP screens
- Customer home screen
- Provider home and provider profile submission screen
- API base URL build configuration
- Android/iOS-ready Flutter source structure

## Build APK on a machine with Flutter installed

```bash
cd mobile-flutter
flutter pub get
flutter run --dart-define=SAWRNI_API_BASE_URL=https://YOUR_BACKEND_DOMAIN/api/v1
```

For APK:

```bash
flutter build apk --release --dart-define=SAWRNI_API_BASE_URL=https://YOUR_BACKEND_DOMAIN/api/v1 --dart-define=SAWRNI_PRODUCTION=true
```

The APK will be in:

```text
mobile-flutter/build/app/outputs/flutter-apk/app-release.apk
```

## Important

Codespaces is useful for storing and editing this source code. Real Android/iOS testing should be done on Android Studio/physical Android phone, or Mac/Xcode for iOS.
