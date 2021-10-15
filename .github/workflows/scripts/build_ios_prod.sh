#!/bin/bash -eu

flutter pub get

APP_NAME=prodアプリ                                                           # FIXME
APP_ASSOCIATED_DOMAIN=applinks:com.example.page.link                       # FIXME
APP_PROVISIONING_PROFILE_SPECIFIER="dev.kingu.myFlutterAppTemplate Ad Hoc" # FIXME
BUNDLE_IDENTIFIER=dev.kingu.myFlutterAppTemplate                           # FIXME

plutil \
  -replace 'provisioningProfiles' \
  -json "{\"${BUNDLE_IDENTIFIER}\":\"${APP_PROVISIONING_PROFILE_SPECIFIER}\"}" \
  .github/workflows/scripts/AdHocExportOptions.plist

fastlane run get_provisioning_profile \
    username:'kanagu@kingu.dev' \
    team_id:'4XBP3H82S7' \
    app_identifier:$BUNDLE_IDENTIFIER \
    adhoc:true \
    readonly:true

flutter build ipa \
  --release \
  --dart-define APP_NAME=$APP_NAME \
  --dart-define APP_ENV=prod \
  --dart-define APP_ASSOCIATED_DOMAIN=$APP_ASSOCIATED_DOMAIN \
  --dart-define APP_PROVISIONING_PROFILE_SPECIFIER="$APP_PROVISIONING_PROFILE_SPECIFIER"
  --export-options-plist=.github/workflows/scripts/AdHocExportOptions.plist

echo "exported to build/ios/ipa/Runner.ipa"

APP_PROVISIONING_PROFILE_SPECIFIER="dev.kingu.myFlutterAppTemplate App Store" # FIXME

plutil \
  -replace 'provisioningProfiles' \
  -json "{\"${BUNDLE_IDENTIFIER}\":\"${APP_PROVISIONING_PROFILE_SPECIFIER}\"}" \
  .github/workflows/scripts/AppStoreExportOptions.plist

fastlane run get_provisioning_profile \
    username:'kanagu@kingu.dev' \
    team_id:'4XBP3H82S7' \
    app_identifier:$BUNDLE_IDENTIFIER \
    adhoc:false \
    readonly:true

xcodebuild -exportArchive \
  -archivePath build/ios/archive/Runner.xcarchive \
  -exportOptionsPlist .github/workflows/scripts/AppStoreExportOptions.plist \
  -exportPath build/ios/appStore
echo "exported to build/ios/appStore/Runner.ipa"

tar cfz build/ios/appStore.tar.gz build/ios/appStore
echo "exported to build/ios/appStore.tar.gz"


