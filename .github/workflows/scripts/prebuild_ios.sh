#!/bin/bash -eu

mobileprovisions=(
    "$MOBILEPROVISION_BASE64_DEV"
    "$MOBILEPROVISION_BASE64_STG"
    "$MOBILEPROVISION_BASE64_PROD"
    "$MOBILEPROVISION_BASE64_APP_STORE"
)

for e in "${mobileprovisions[@]}"; do
    if [ -z $e ]; then
        echo "skip"
    else
        PP_PATH=build_ios_$RANDOM.mobileprovision
        echo $e | base64 --decode --output $PP_PATH
        echo "copy $PP_PATH"
        cp $PP_PATH ~/Library/MobileDevice/Provisioning\ Profiles
    fi
done

keychain_password=$(openssl rand -base64 12 | fold -w 10 | head -1)

fastlane run create_keychain \
    name:'ios-build.keychain' \
    password:$keychain_password \
    default_keychain:false \
    unlock:true \
    timeout:3600

echo $P12_BASE64 | base64 --decode --output target.p12

fastlane run import_certificate \
    certificate_path:'target.p12' \
    certificate_password:$P12_PASSWORD \
    keychain_name:'ios-build.keychain' \
    keychain_password:$keychain_password \
    log_output:true
