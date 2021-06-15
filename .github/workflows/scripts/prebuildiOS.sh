#!/bin/bash -e

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
        echo $e | base64 -d >target.mobileprovision
        fastlane run install_provisioning_profile path:"target.mobileprovision"
    fi
done

fastlane run create_keychain \
    name:'ios-build.keychain' \
    password:$KEYCHAIN_PASSWORD \
    default_keychain:false \
    unlock:true \
    timeout:3600

echo $P12_BASE64 | base64 -d >target.p12

fastlane run import_certificate \
    certificate_path:'target.p12' \
    certificate_password:$P12_PASSWORD \
    keychain_name:'ios-build.keychain' \
    keychain_password:$KEYCHAIN_PASSWORD \
    log_output:true
