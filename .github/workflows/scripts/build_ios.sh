#!/bin/bash -eu

if [ $# -ne 3 ]; then
  echo "e.g. ./build_ios dev 1.2.3 100" 1>&2
  exit 1
fi

flutter pub get

case $1 in
"dev")
  APP_NAME=devアプリ # FIXME
  APP_SUFFIX=.dev
  APP_ASSOCIATED_DOMAIN=applinks:com.example.page.link                           # FIXME
  APP_PROVISIONING_PROFILE_SPECIFIER="dev.kingu.myFlutterAppTemplate.dev Ad Hoc" # FIXME
  BUNDLE_IDENTIFIER=dev.kingu.myFlutterAppTemplate.dev                           # FIXME

  plutil \
    -replace 'provisioningProfiles' \
    -json "{\"${BUNDLE_IDENTIFIER}\":\"${APP_PROVISIONING_PROFILE_SPECIFIER}\"}" \
    .github/workflows/scripts/AdHocExportOptions.plist

  flutter build ipa \
    --release \
    --dart-define APP_NAME=$APP_NAME \
    --dart-define APP_SUFFIX=$APP_SUFFIX \
    --dart-define APP_ENV=$1 \
    --dart-define APP_ASSOCIATED_DOMAIN=$APP_ASSOCIATED_DOMAIN \
    --dart-define APP_PROVISIONING_PROFILE_SPECIFIER="$APP_PROVISIONING_PROFILE_SPECIFIER" \
    --build-name $2 \
    --build-number $3 \
    --export-options-plist=.github/workflows/scripts/AdHocExportOptions.plist
  ;;
"stg")
  APP_NAME=stgアプリ # FIXME
  APP_SUFFIX=.stg
  APP_ASSOCIATED_DOMAIN=applinks:com.example.page.link                           # FIXME
  APP_PROVISIONING_PROFILE_SPECIFIER="dev.kingu.myFlutterAppTemplate.stg Ad Hoc" # FIXME
  BUNDLE_IDENTIFIER=dev.kingu.myFlutterAppTemplate.stg                           # FIXME

  plutil \
    -replace 'provisioningProfiles' \
    -json "{\"${BUNDLE_IDENTIFIER}\":\"${APP_PROVISIONING_PROFILE_SPECIFIER}\"}" \
    .github/workflows/scripts/AdHocExportOptions.plist

  flutter build ipa \
    --release \
    --dart-define APP_NAME=$APP_NAME \
    --dart-define APP_SUFFIX=$APP_SUFFIX \
    --dart-define APP_ENV=$1 \
    --dart-define APP_ASSOCIATED_DOMAIN=$APP_ASSOCIATED_DOMAIN \
    --dart-define APP_PROVISIONING_PROFILE_SPECIFIER="$APP_PROVISIONING_PROFILE_SPECIFIER" \
    --build-name $2 \
    --build-number $3 \
    --export-options-plist=.github/workflows/scripts/AdHocExportOptions.plist
  ;;
"prod")
  APP_NAME=prodアプリ                                                           # FIXME
  APP_ASSOCIATED_DOMAIN=applinks:com.example.page.link                       # FIXME
  APP_PROVISIONING_PROFILE_SPECIFIER="dev.kingu.myFlutterAppTemplate Ad Hoc" # FIXME
  BUNDLE_IDENTIFIER=dev.kingu.myFlutterAppTemplate                           # FIXME

  plutil \
    -replace 'provisioningProfiles' \
    -json "{\"${BUNDLE_IDENTIFIER}\":\"${APP_PROVISIONING_PROFILE_SPECIFIER}\"}" \
    .github/workflows/scripts/AdHocExportOptions.plist

  flutter build ipa \
    --release \
    --dart-define APP_NAME=$APP_NAME \
    --dart-define APP_ENV=$1 \
    --dart-define APP_ASSOCIATED_DOMAIN=$APP_ASSOCIATED_DOMAIN \
    --dart-define APP_PROVISIONING_PROFILE_SPECIFIER="$APP_PROVISIONING_PROFILE_SPECIFIER" \
    --build-name $2 \
    --build-number $3 \
    --export-options-plist=.github/workflows/scripts/AdHocExportOptions.plist

  APP_PROVISIONING_PROFILE_SPECIFIER="dev.kingu.myFlutterAppTemplate App Store" # FIXME
  plutil \
    -replace 'provisioningProfiles' \
    -json "{\"${BUNDLE_IDENTIFIER}\":\"${APP_PROVISIONING_PROFILE_SPECIFIER}\"}" \
    .github/workflows/scripts/AppStoreExportOptions.plist

  xcodebuild -exportArchive \
    -archivePath build/ios/archive/Runner.xcarchive \
    -exportOptionsPlist .github/workflows/scripts/AppStoreExportOptions.plist \
    -exportPath build/ios/appStore
  echo "exported to build/ios/appStore/Runner.ipa"

  tar cfz build/ios/appStore.tar.gz build/ios/appStore
  echo "exported to build/ios/appStore.tar.gz"
  ;;
*)
  echo "unknown env: $1"
  exit 1
  ;;
esac

echo "exported to build/ios/ipa/Runner.ipa"

tar cfz build/ios/ipa.tar.gz build/ios/ipa
echo "exported to build/ios/ipa.tar.gz"
