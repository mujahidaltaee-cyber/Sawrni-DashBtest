from pathlib import Path

manifest = Path("android/app/src/main/AndroidManifest.xml")
if not manifest.exists():
    print("AndroidManifest.xml not found yet. Run: flutter create --platforms=android .")
    raise SystemExit(0)

text = manifest.read_text(encoding="utf-8")
permissions = [
    '<uses-permission android:name="android.permission.INTERNET" />',
    '<uses-permission android:name="android.permission.CAMERA" />',
    '<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />',
    '<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />',
]

for permission in permissions:
    if permission not in text:
        text = text.replace("<application", f"    {permission}\n    <application", 1)

# Keep app label Arabic-first for Android launcher.
text = text.replace('android:label="sawrni_mobile"', 'android:label="صورني"')
text = text.replace('android:label="sawrni"', 'android:label="صورني"')

manifest.write_text(text, encoding="utf-8")
print("Android manifest patched for Sawrni build.")
