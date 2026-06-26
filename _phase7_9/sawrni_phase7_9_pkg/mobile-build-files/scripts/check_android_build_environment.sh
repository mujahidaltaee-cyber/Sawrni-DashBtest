#!/usr/bin/env bash
set -euo pipefail

echo "Sawrni Android build environment check"
echo "Slogan: استوديو كامل بجيبك"

if command -v flutter >/dev/null 2>&1; then
  flutter --version
  flutter doctor
else
  echo "Flutter: NOT FOUND"
fi

if command -v java >/dev/null 2>&1; then
  java -version
else
  echo "Java: NOT FOUND"
fi

if [ -n "${ANDROID_HOME:-}" ]; then
  echo "ANDROID_HOME=$ANDROID_HOME"
else
  echo "ANDROID_HOME is not set"
fi
