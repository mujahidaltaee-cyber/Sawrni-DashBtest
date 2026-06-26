# Sawrni Phase 7.9 — Android APK Build Preparation

Brand slogan:

**استوديو كامل بجيبك**

## What this phase prepares

- Android package/build workflow for the real Flutter app.
- Environment configuration using `--dart-define`.
- Debug APK build script.
- Android manifest patch helper for app permissions.
- Local Windows build instructions.
- Brand asset folder for icon/splash/logo.

## Important

Codespaces usually cannot run the Android emulator. Use Codespaces for source code, then build/test APK on:

- Windows PC with Flutter + Android Studio, or
- Mac with Flutter + Android Studio/Xcode, or
- a cloud CI build service later.

## Recommended Android package name

```text
com.sawrni.app
```

## API base URL

For production later:

```text
https://api.sawrni.com/api/v1
```

For local testing from Android phone, use your computer LAN IP, not `localhost`:

```text
http://192.168.x.x:8010/api/v1
```

For Android emulator:

```text
http://10.0.2.2:8010/api/v1
```

## Build on Windows

From the repo root:

```powershell
cd mobile-flutter
flutter create --platforms=android . --project-name sawrni_mobile --org com.sawrni
flutter pub get
python scripts/patch_android_manifest.py
flutter build apk --debug --dart-define=SAWRNI_API_BASE_URL="http://10.0.2.2:8010/api/v1"
```

APK output:

```text
mobile-flutter/build/app/outputs/flutter-apk/app-debug.apk
```

Install it on Android:

```powershell
flutter install
```

or copy the APK to the phone and install it manually.

## Build with script

Linux/Mac/Git Bash:

```bash
cd mobile-flutter
SAWRNI_API_BASE_URL="http://10.0.2.2:8010/api/v1" bash scripts/build_android_debug.sh
```

Windows PowerShell:

```powershell
cd mobile-flutter
$env:SAWRNI_API_BASE_URL="http://10.0.2.2:8010/api/v1"
.\scripts\build_android_debug.bat
```

## Brand files

Put final exported visual identity files here:

```text
mobile-flutter/assets/brand/
```

Recommended names:

```text
logo.png
icon.png
splash.png
wordmark.png
```
