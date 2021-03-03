// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AUEtherCapture",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "BinaryReader", url: "https://github.com/rinsuki/BinaryReaderSwift", .branch("master")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/sharplet/Regex", from: "2.1.1"),
        .package(url: "https://github.com/rinsuki/SwiftMsgPack", .branch("implement/handling-nsnull")),
        
        .package(name: "Gzip", url: "https://github.com/1024jp/GzipSwift", from: "5.1.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "AUEtherCapture", dependencies: [
                    "Pcap",
                    "BinaryReader",
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                    "Regex",
                    "SwiftMsgPack",
                    "Gzip",
        ]),
        .target(name: "Pcap", dependencies: ["libpcap"]),
        .systemLibrary(name: "libpcap", pkgConfig: "libpcap", providers: []),
        .testTarget(name: "AUEtherCaptureTests", dependencies: ["AUEtherCapture"]),
    ]
)
