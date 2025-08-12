// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoginIDMFA",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LoginIDMFA",
            targets: ["LoginIDMFA"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LoginIDAPIClient"
            // If the folder name differs, specify: path: "Sources/LoginIDAPIClient"
        ),
        .target(
            name: "LoginIDMFA",
            dependencies: [
                // Make MFA depend on the client module
                .target(name: "LoginIDAPIClient")
            ]
            // path: "Sources/LoginIDMFA"  // only needed if you don't follow the default layout
        ),
        .testTarget(
            name: "LoginIDMFATests",
            dependencies: ["LoginIDMFA"]
        ),
    ]
)
