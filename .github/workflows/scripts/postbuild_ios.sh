#!/bin/bash

fastlane run delete_keychain name:'ios-build.keychain'
rm fastlaneApiKey.json