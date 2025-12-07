// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "swift-leeds",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/swift-aws/aws-sdk-swift.git", from: "4.7.0"),
        .package(url: "https://github.com/vapor/apns.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/handya/markdown.git", branch: "fix/xcode-16"),
        .package(url: "https://github.com/vapor/jwt.git", from: "5.0.0"),
        .package(url: "https://github.com/brainfinance/StackdriverLogging.git", from: "4.2.0"),
        
        // This package is used by AWSSDKSwiftCore on Linux only. We add it here (but don't utilise it) in order to
        // add it to the Package.resolved file. This ensures that when Docker resolves this project, it will not ignore
        // the versions pinned (causing a disparity between production Linux releases and local macOS builds). This also
        // massively improves build times by preventing multiple resolution cycles on deploy.
        .package(url: "https://github.com/apple/swift-nio-ssl-support.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "S3", package: "aws-sdk-swift"),
                .product(name: "SwiftMarkdown", package: "markdown"),
                .product(name: "VaporAPNS", package: "apns"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "StackdriverLogging", package: "StackdriverLogging"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
