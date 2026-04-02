#!/bin/bash

cd "$(dirname "$0")"
cd ..

SCHEME="MathCurveLoadingIndicator"
WORKSPACE="./MathCurve.xcworkspace"
APP_SCHEME="MatchCurve"

set -e

echo "[*] running swift test"
swift test
echo "[*] swift test passed"

function test_build() {
    DESTINATION=$1
    echo "[*] test build for $DESTINATION"
    xcodebuild \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -configuration Release \
        clean build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_ALLOWED=NO \
        -quiet
    echo "[*] build succeeded for $DESTINATION"
}

function test_app_build() {
    DESTINATION=$1
    echo "[*] test app build for $DESTINATION"
    xcodebuild \
        -workspace "$WORKSPACE" \
        -scheme "$APP_SCHEME" \
        -destination "$DESTINATION" \
        -configuration Release \
        clean build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_ALLOWED=NO \
        -quiet
    echo "[*] app build succeeded for $DESTINATION"
}

if [ -n "$BUILD_DESTINATION" ]; then
    test_build "$BUILD_DESTINATION"
elif [ -n "$APP_BUILD_DESTINATION" ]; then
    test_app_build "$APP_BUILD_DESTINATION"
else
    test_build "generic/platform=macOS"
    test_build "generic/platform=macOS,variant=Mac Catalyst"
    test_build "generic/platform=iOS"
    test_build "generic/platform=iOS Simulator"
    test_build "generic/platform=tvOS"
    test_build "generic/platform=tvOS Simulator"
    test_build "generic/platform=xrOS"
    test_build "generic/platform=xrOS Simulator"

    echo "[*] all library builds succeeded"

    test_app_build "generic/platform=macOS"
    test_app_build "generic/platform=iOS"
    test_app_build "generic/platform=xrOS"

    echo "[*] all builds succeeded"
fi
