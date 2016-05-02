#!/usr/bin/env bash

set -e

xctool -project ReflectedStringConvertible.xcodeproj -scheme "ReflectedStringConvertible OSX" test
xctool -project ReflectedStringConvertible.xcodeproj -scheme "ReflectedStringConvertible iOS" -sdk iphonesimulator9.3 -destination "platform=iOS Simulator,name=iPhone 6" test