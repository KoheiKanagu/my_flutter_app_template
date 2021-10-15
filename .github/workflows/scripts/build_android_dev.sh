#!/bin/bash -eu

flutter pub get

APP_NAME=devアプリ # FIXME

flutter build apk \
  --release \
  --target-platform android-arm64 \
  --dart-define APP_NAME=$APP_NAME \
  --dart-define APP_SUFFIX=.dev \
  --dart-define APP_ENV=dev
echo "exported to build/app/outputs/flutter-apk/app-release.apk"
