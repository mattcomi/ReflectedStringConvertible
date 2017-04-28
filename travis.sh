#!/usr/bin/env bash

set -e
set -o pipefail && xcodebuild -scheme "ReflectedStringConvertible OSX" build 
set -o pipefail && xcodebuild -scheme "ReflectedStringConvertible iOS" build
xctool -scheme "ReflectedStringConvertible OSX" run-tests
xctool -scheme "ReflectedStringConvertible iOS" -sdk iphonesimulator10.1 -destination "platform=iOS Simulator,name=iPhone 7" run-tests
