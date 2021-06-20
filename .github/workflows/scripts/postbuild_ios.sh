#!/bin/bash

fastlane run delete_keychain name:'ios-build.keychain'

rm -f ~/Library/MobileDevice/Provisioning\ Profiles/build_ios_*.mobileprovision
