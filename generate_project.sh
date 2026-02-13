#!/usr/bin/env bash
set -e
echo "Generating Xcode project via XcodeGen..."
xcodegen generate
echo "Done. Open MobileFieldChecklistApp.xcodeproj"
