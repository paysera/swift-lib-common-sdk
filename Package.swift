// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "PayseraCommonSDK",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "PayseraCommonSDK", targets: ["PayseraCommonSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", .exact("5.4.4")),
        .package(name: "JWTDecode", url: "https://github.com/auth0/JWTDecode.swift", .exact("2.6.3")),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper", .exact("4.2.0")),
        .package(url: "https://github.com/mxcl/PromiseKit", .exact("6.16.2")),
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
