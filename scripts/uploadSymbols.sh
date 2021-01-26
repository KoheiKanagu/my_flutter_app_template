#!/bin/bash -eu

if [ $# -ne 2 ]; then
  echo "e.g. ./uploadSymbols.sh /PATH/TO/ios/Runner/GoogleService-Info-prod.plist /PATH/TO/appDsyms" 1>&2
  exit 1
fi

./ios/Pods/FirebaseCrashlytics/upload-symbols -gsp $1 -p ios $2
