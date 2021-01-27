#!/bin/sh
# Flutterのプロジェクトルートで実行すること
# 詳細: https://qiita.com/KoheiKanagu/items/516f43686b3f96fc3022#%E6%A7%8B%E6%88%90%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB

function fetchAndroid() {
  JSON_PATH=android/app/google-services-$1.json
  rm $JSON_PATH
  firebase apps:sdkconfig ios $2 --out $JSON_PATH
}

function fetchiOS() {
  PLIST_PATH=ios/Runner/GoogleService-Info-$1.plist
  rm $PLIST_PATH
  firebase apps:sdkconfig ios $2 --out $PLIST_PATH
}

echo "==== dev ===="

fetchiOS dev 1:TODO:ios:TODO
fetchAndroid dev 1:TODO:android:TODO

echo "==== stg ===="

fetchiOS stg 1:TODO:ios:TODO
fetchAndroid stg 1:TODO:android:TODO

echo "==== prod ===="

fetchiOS prod 1:TODO:ios:TODO
fetchAndroid prod 1:TODO:android:TODO
