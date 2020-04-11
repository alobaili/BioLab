// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "BioLab",
    products: [
        .library(name: "BioLab", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on MySQL 3.
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),
        
        // Leaf
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentMySQL", "Vapor", "Leaf"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

