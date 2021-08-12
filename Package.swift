// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "PayseraCommonSDK",
    platforms: [.macOS(.v10_12), .iOS(.v10), .tvOS(.v9), .watchOS(.v2)],
    products: [
        .library(name: "PayseraCommonSDK", targets: ["PayseraCommonSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", .branch("xcode13")),
        .package(name: "JWTDecode", url: "https://github.com/auth0/JWTDecode.swift", .exact("2.6.1")),
        .package(url: "https://github.com/Hearst-DD/ObjectMapper", .exact("4.2.0")),
        .package(url: "https://github.com/mxcl/PromiseKit", .exact("6.15.3")),
    ],
    targets: [
        .target(
            name: "PayseraCommonSDK",
            dependencies: ["Alamofire", "PromiseKit", "ObjectMapper", "JWTDecode"]
        ),
        .testTarget(
            name: "PayseraCommonSDKTests",
            dependencies: ["PayseraCommonSDK"]
        ),
    ]
)
