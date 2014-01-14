#!/bin/bash

cd "`dirname \"$0\"`"
SCRIPT_WD=`pwd`

PRODUCT_NAME="CodePilot3"
PACKAGEMAKER_PATH="/Applications/PackageMaker.app"

if [ ! -d "$PACKAGEMAKER_PATH" ]; then
    echo "Could not locate PackageMaker.app. You can download it from https://developer.apple.com/downloads (Auxiliary tools for Xcode)"
	exit 1
fi

if [ -z "$PROJECT_DIR" ]; then
    # Script invoked outside of Xcode, figure out environmental vars for ourself.
    PROJECT_DIR='..'
    BUILT_PRODUCTS_DIR="$PROJECT_DIR/build/Release"
    CONFIGURATION='Release'
    BUILT_PLUGIN="$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.xcplugin"
    PRODUCT_VERSION=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$BUILT_PLUGIN/Contents/Info.plist"`
else
    PRODUCT_VERSION=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$PROJECT_DIR/Resources/Info.plist"`
fi

if [ "$CONFIGURATION" != "Release" ]; then
    echo "Could not generate package."
    echo "Active Configuration needs to be set to 'Release'."
    exit 1
fi

MY_INSTALLER_ROOT="$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.dst"
BUILT_PLUGIN="$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.xcplugin"
VERSIONED_NAME="$PRODUCT_NAME-$PRODUCT_VERSION"
BUILT_PKG="$BUILT_PRODUCTS_DIR/$VERSIONED_NAME.pkg"

# Delete old files if they're around.
if [ -d "$MY_INSTALLER_ROOT" ]; then
	rm -rf "$MY_INSTALLER_ROOT"
fi

if [ -d "$BUILT_PKG" ]; then
	rm -rf "$BUILT_PKG"
fi

# Create the .pkg.
mkdir "$MY_INSTALLER_ROOT"
cp -R "$BUILT_PLUGIN" "$MY_INSTALLER_ROOT"

"$PACKAGEMAKER_PATH/Contents/MacOS/PackageMaker" \
	--root "$MY_INSTALLER_ROOT" \
	--info "Info.plist" \
	--resources resources \
	--scripts scripts \
	--target 10.4 \
	--version "$PRODUCT_VERSION" \
	--verbose \
	--out "$BUILT_PKG"

echo Package ready: 
ls -dl "$BUILT_PKG"
du -hs "$BUILT_PKG"
rm -rf "$MY_INSTALLER_ROOT"


cd "`dirname $BUILT_PKG`"
zip -r "$VERSIONED_NAME.zip" "$VERSIONED_NAME.pkg"

echo ZIP file ready: 
ls -l "$VERSIONED_NAME.zip"

