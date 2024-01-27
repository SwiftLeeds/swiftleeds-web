// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "swift-leeds",
    platforms: [
        .macOS(.v12),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/swift-aws/aws-sdk-swift.git", from: "4.7.0"),
        .package(url: "https://github.com/vapor-community/leaf-markdown.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/vapor/apns.git", from: "1.0.0"),
        
        // This package is used by AWSSDKSwiftCore on Linux only. We add it here (but don't utilise it) in order to
        // add it to the Package.resolved file. This ensures that when Docker or Heroku resolves this project, it will not
        // ignore the versions pinned (causing a disparity between production Linux releases and local macOS builds).
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
                .product(name: "LeafMarkdown", package: "leaf-markdown"),
                .product(name: "APNS", package: "apns"),
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ]
        ),
    ]
)
