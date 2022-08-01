// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProteinKit",
    platforms: [.iOS(.v13),.macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ProteinKit",
            targets: ["ProteinKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/heckj/MeshGenerator", branch: "main"),
        .package(url: "https://github.com/chdominguez/SceneKitPlus", branch: "main")
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "CStride",
                dependencies: [],
                path: "Sources/Stride"),
        .target(name: "ProteinKit",
                dependencies: ["CStride", "SceneKitPlus", "MeshGenerator"]),
        .testTarget(
            name: "ProteinKitTests",
            dependencies: ["ProteinKit", "SceneKitPlus"])
    ]
)
