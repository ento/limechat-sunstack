#/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
NORMAL_ID=LimeChat
APPSTORE_ID=net.limechat.LimeChat-AppStore
THEME_DIR=

make_theme_dir () {
  echo /Users/ento/Library/Application Support/$1/Themes/
}

for bundle_id in $NORMAL_ID $APPSTORE_ID; do
  theme_dir="$(make_theme_dir $bundle_id)"
  if [ -d "$theme_dir" ]; then
    THEME_DIR=$theme_dir
    break
  fi
done

if [ -z "$THEME_DIR" ]; then
  plist_bundle_id=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" /Applications/LimeChat.app/Contents/Info.plist)
  if [[ "$plist_bundle_id" == *AppStore* ]]; then
    bundle_id=$APPSTORE_ID
  else
    bundle_id=$NORMAL_ID
  fi
  THEME_DIR="$(make_theme_dir $bundle_id)"
  mkdir -p $THEME_DIR
fi

find "$DIR" \( -iname "*.css" -o -iname "*.yaml" \) -exec ln -sf '{}' "$THEME_DIR" \;
