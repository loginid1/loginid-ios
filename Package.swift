// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "LoginID",
    platforms: [
        .iOS(.v16),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "LoginIDCore",
            targets: ["LoginIDCore"]
        ),
        .library(
            name: "LoginIDAuth",
            targets: ["LoginIDAuth"]
        ),
        .library(
            name: "LoginIDMFA",
            targets: ["LoginIDMFA"]
        ),
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "LoginIDCore",
            path: "LoginIDCore/Sources"
        ),
        .testTarget(
            name: "LoginIDCoreTests",
            dependencies: ["LoginIDCore"],
            path: "LoginIDCore/Tests"
        ),

        // MARK: - Auth
        .target(
            name: "LoginIDAuth",
            dependencies: ["LoginIDCore"],
            path: "LoginIDAuth/Sources"
        ),
        .testTarget(
            name: "LoginIDAuthTests",
            dependencies: ["LoginIDAuth"],
            path: "LoginIDAuth/Tests"
        ),

        // MARK: - MFA
        .target(
            name: "LoginIDAPIClient",
            path: "LoginIDMFA/Sources/LoginIDAPIClient"
        ),
        .target(
            name: "LoginIDMFA",
            dependencies: [
                "LoginIDAPIClient",
                "LoginIDCore"
            ],
            path: "LoginIDMFA/Sources/LoginIDMFA"
        ),
        .testTarget(
            name: "LoginIDMFATests",
            dependencies: ["LoginIDMFA"],
            path: "LoginIDMFA/Tests"
        ),
    ]
)
