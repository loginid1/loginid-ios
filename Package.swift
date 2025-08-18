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
            name: "LoginIDMFA",
            targets: ["LoginIDMFA"]
        ),
        .library(
            name: "LoginIDWalletAuth",
            targets: ["LoginIDWalletAuth"]
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

        // MARK: - WalletAuth
        .target(
            name: "LoginIDWalletAuth",
            dependencies: ["LoginIDMFA"],
            path: "LoginIDWalletAuth/Sources"
        ),
        .testTarget(
            name: "LoginIDWalletAuthTests",
            dependencies: ["LoginIDWalletAuth"],
            path: "LoginIDWalletAuth/Tests"
        ),
    ]
)
