#!/bin/bash -eu
# 参考: https://qiita.com/KoheiKanagu/items/516f43686b3f96fc3022#cicd%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6

if [ $# -ne 3 ]; then
  echo "e.g. ./buildAndroid dev 1.2.3 100" 1>&2
  exit 1
fi

flutter pub get

case $1 in
"dev")
  APP_NAME=devアプリ
  APP_SUFFIX=.dev

  flutter build apk \
    --release \
    --target-platform android-arm64 \
    --dart-define APP_NAME=$APP_NAME \
    --dart-define APP_SUFFIX=$APP_SUFFIX \
    --dart-define APP_ENV=$1 \
    --build-name $2 \
    --build-number $3
  echo "exported to build/app/outputs/flutter-apk/app-release.apk"
  ;;
"stg")
  APP_NAME=stgアプリ
  APP_SUFFIX=.stg

  flutter build apk \
    --release \
    --target-platform android-arm64 \
    --dart-define APP_NAME=$APP_NAME \
    --dart-define APP_SUFFIX=$APP_SUFFIX \
    --dart-define APP_ENV=$1 \
    --build-name $2 \
    --build-number $3
  echo "exported to build/app/outputs/flutter-apk/app-release.apk"
  ;;
"prod")
  APP_NAME=prodアプリ

  flutter build apk \
    --release \
    --target-platform android-arm64 \
    --dart-define APP_NAME=$APP_NAME \
    --dart-define APP_ENV=$1 \
    --build-name $2 \
    --build-number $3
  echo "exported to build/app/outputs/flutter-apk/app-release.apk"

  flutter build appbundle \
    --release \
    --dart-define APP_NAME=$APP_NAME \
    --dart-define APP_ENV=$1 \
    --build-name $2 \
    --build-number $3
  echo "exported to build/app/outputs/bundle/release/app-release.aab"
  ;;
*)
  echo "unknown env: $1"
  exit 1
  ;;
esac