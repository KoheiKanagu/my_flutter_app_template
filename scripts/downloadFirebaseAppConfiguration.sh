#!/bin/bash -eu
# Flutterのプロジェクトルートで実行すること
# 詳細: https://qiita.com/KoheiKanagu/items/516f43686b3f96fc3022#%E6%A7%8B%E6%88%90%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB

function fetchAndroid() {
  JSON_PATH=android/app/google-services-$1.json
  rm -f $JSON_PATH
  firebase apps:sdkconfig android $2 --out $JSON_PATH
}

function fetchiOS() {
  PLIST_PATH=ios/Runner/GoogleService-Info-$1.plist
  rm -f $PLIST_PATH
  firebase apps:sdkconfig ios $2 --out $PLIST_PATH
}

echo "==== dev ===="

fetchiOS dev 1:636844036668:ios:ccca644085de25c822a939         # FIXME
fetchAndroid dev 1:636844036668:android:b09e49dce9d3527922a939 # FIXME

echo "==== stg ===="

fetchiOS stg 1:970978420457:ios:b7ecc1d711f47cd3bfb278         # FIXME
fetchAndroid stg 1:970978420457:android:d18cddc337585761bfb278 # FIXME

echo "==== prod ===="

fetchiOS prod 1:1066701925010:ios:43c5707102329348e3944b         # FIXME
fetchAndroid prod 1:1066701925010:android:51be10ae2c513cc9e3944b # FIXME
