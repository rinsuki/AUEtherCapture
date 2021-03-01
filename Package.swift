// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AUEtherCapture",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "BinaryReader", url: "https://github.com/rinsuki/BinaryReaderSwift", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "AUEtherCapture", dependencies: ["Pcap", "BinaryReader"]),
        .target(name: "Pcap", dependencies: ["libpcap"]),
        .systemLibrary(name: "libpcap", pkgConfig: "libpcap", providers: []),
        .testTarget(name: "AUEtherCaptureTests", dependencies: ["AUEtherCapture"]),
    ]
)
