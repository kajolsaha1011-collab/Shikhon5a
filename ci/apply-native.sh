#!/usr/bin/env bash
# ব্যাকগ্রাউন্ডে ভিডিও চালু রাখার নেটিভ কোড ও অনুমতি Android প্রজেক্টে বসায়।
# android.yml ও release-aab.yml দুটোই এটি চালায়। (cap add android-এর পর চলে)
set -euo pipefail

PKG_DIR="android/app/src/main/java/com/abhi/shikhon"
MANIFEST="android/app/src/main/AndroidManifest.xml"

test -f "$MANIFEST" || { echo "AndroidManifest.xml পাওয়া যায়নি"; exit 1; }
mkdir -p "$PKG_DIR"
cp android-res/java/*.java "$PKG_DIR/"

# অনুমতি (একবারই বসবে)
if ! grep -q "FOREGROUND_SERVICE_MEDIA_PLAYBACK" "$MANIFEST"; then
  sed -i 's#<application#<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />\n    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />\n    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />\n    <uses-permission android:name="android.permission.WAKE_LOCK" />\n    <application#' "$MANIFEST"
fi

# সার্ভিস ঘোষণা
if ! grep -q "KeepAliveService" "$MANIFEST"; then
  sed -i 's#</application>#    <service android:name=".KeepAliveService" android:exported="false" android:foregroundServiceType="mediaPlayback" />\n    </application>#' "$MANIFEST"
fi

grep -q "KeepAliveService" "$MANIFEST" || { echo "সার্ভিস বসানো যায়নি"; exit 1; }
grep -q "FOREGROUND_SERVICE_MEDIA_PLAYBACK" "$MANIFEST" || { echo "অনুমতি বসানো যায়নি"; exit 1; }
ls "$PKG_DIR"
echo "---- AndroidManifest.xml ----"
cat "$MANIFEST"
