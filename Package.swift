// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReflectedStringConvertible",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11),
        .watchOS(.v2),
    ],
    products: [
        .library(
            name: "ReflectedStringConvertible",
            targets: ["ReflectedStringConvertible"]),
    ],
    targets: [
        .target(
            name: "ReflectedStringConvertible",
            dependencies: [],
            path: "ReflectedStringConvertible",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "ReflectedStringConvertibleTests",
            dependencies: ["ReflectedStringConvertible"],
            path: "ReflectedStringConvertibleTests",
            exclude: [
                "Info.plist",
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
