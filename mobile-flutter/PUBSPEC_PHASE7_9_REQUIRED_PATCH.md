# Sawrni Phase 7.9 required pubspec additions

Make sure `mobile-flutter/pubspec.yaml` contains these sections before building APK:

```yaml
dependencies:
  http: ^1.2.2

dev_dependencies:
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.4.1

flutter:
  uses-material-design: true
  assets:
    - assets/brand/

flutter_launcher_icons:
  android: true
  ios: true
  image_path: assets/brand/icon.png
  adaptive_icon_background: '#071326'
  adaptive_icon_foreground: assets/brand/icon.png

flutter_native_splash:
  color: '#071326'
  image: assets/brand/splash.png
  android: true
  ios: true
```

If `icon.png` or `splash.png` are not ready yet, keep the files as placeholders and replace them later with the final visual identity export.
