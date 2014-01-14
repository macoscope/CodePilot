#!/bin/bash

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")" && cd .. && pwd)"

CODE_PILOT_PROJ_PATH="$PROJECT_ROOT/CodePilot.xcodeproj"

XCODE_PROC_NAME="Xcode"
XCODE_APP_PATH="/Applications/Xcode.app"

PLUGIN_NAME="CodePilot3.xcplugin"
PLUGIN_SRC="$(echo ~/Library/Developer/Xcode/DerivedData/CodePilot-*/Build/Products/Debug)"
PLUGIN_DEST="$(echo ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins)"

echo Building the plugin
xcodebuild -project "$CODE_PILOT_PROJ_PATH" -configuration Debug -scheme CodePilot

echo Making sure the plugin directory exists
mkdir -p "$PLUGIN_DEST"

echo Removing the old plugin if there is one
rm -rf   "$PLUGIN_DEST/$PLUGIN_NAME"

echo Copying the new plugin into the plugin directory
cp -R    "$PLUGIN_SRC/$PLUGIN_NAME" "$PLUGIN_DEST/"

echo Closing Xcode
if ! killall "$XCODE_PROC_NAME"; then
    echo Xcode wasnt open
fi

echo Reopening Xcode

for i in `seq 3`; do
    sleep 1
    echo -ne .
done

echo

open     "$XCODE_APP_PATH"

echo CodePilot plugin replaced successfully
