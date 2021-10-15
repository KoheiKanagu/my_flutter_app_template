#!/bin/bash -eu

flutter pub get

APP_NAME=prodアプリ # FIXME

flutter build apk \
  --release \
  --target-platform android-arm64 \
  --dart-define APP_NAME=$APP_NAME \
  --dart-define APP_ENV=prod
echo "exported to build/app/outputs/flutter-apk/app-release.apk"

flutter build appbundle \
  --release \
  --dart-define APP_NAME=$APP_NAME \
  --dart-define APP_ENV=prod
echo "exported to build/app/outputs/bundle/release/app-release.aab"
