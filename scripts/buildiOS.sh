#!/bin/bash -eu
# 参考: https://qiita.com/KoheiKanagu/items/516f43686b3f96fc3022#cicd%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6

if [ $# -ne 3 ]; then
  echo "e.g. ./buildiOS dev 1.2.3 100" 1>&2
  exit 1
fi

pod repo update
flutter pub get

case $1 in
"dev")
  APP_NAME=devアプリ
  APP_SUFFIX=.dev
  APP_ASSOCIATED_DOMAIN=applinks:exampledev.page.link

  flutter build ios \
    --release \
    --dart-define APP_NAME=$APP_NAME \
    --dart-define APP_SUFFIX=$APP_SUFFIX \
    --dart-define APP_ENV=$1 \
    --dart-define APP_ASSOCIATED_DOMAIN=$APP_ASSOCIATED_DOMAIN \
    --build-name $2 \
    --build-number $3
  ;;
"stg")
  APP_NAME=stgアプリ
  APP_SUFFIX=.stg
  APP_ASSOCIATED_DOMAIN=applinks:examplestg.page.link

  flutter build ios \
    --release \
    --dart-define APP_NAME=$APP_NAME \
    --dart-define APP_SUFFIX=$APP_SUFFIX \
    --dart-define APP_ASSOCIATED_DOMAIN=$APP_ASSOCIATED_DOMAIN \
    --dart-define APP_ENV=$1 \
    --build-name $2 \
    --build-number $3
  ;;
"prod")
  APP_NAME=prodアプリ
  APP_ASSOCIATED_DOMAIN=applinks:example.page.link

  flutter build ios \
    --release \
    --dart-define APP_NAME=$APP_NAME \
    --dart-define APP_ENV=$1 \
    --dart-define APP_ASSOCIATED_DOMAIN=$APP_ASSOCIATED_DOMAIN \
    --build-name $2 \
    --build-number $3
  ;;
*)
  echo "unknown env: $1"
  exit 1
  ;;
esac

xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -sdk iphoneos archive \
  -archivePath build/archive \
  -quiet
echo "exported to build/archive.xcarchive"

tar cfz build/archive.xcarchive.tar.gz build/archive.xcarchive
echo "exported to build/archive.xcarchive.tar.gz"

xcodebuild -exportArchive \
  -archivePath build/archive.xcarchive \
  -exportOptionsPlist scripts/AdHocExportOptions.plist \
  -exportPath build/export \
  -allowProvisioningUpdates \
  -allowProvisioningDeviceRegistration
echo "exported to build/export/Runner.ipa"

case $1 in
"prod")
  xcodebuild -exportArchive \
    -archivePath build/archive.xcarchive \
    -exportOptionsPlist scripts/AppStoreExportOptions.plist \
    -exportPath build/export/appStore \
    -allowProvisioningUpdates
  echo "exported to build/export/appStore/Runner.ipa"

  tar cfz build/export/appStore.tar.gz build/export/appStore
  echo "exported to build/export/appStore.tar.gz"
  ;;
*)
  exit 0
  ;;
esac
