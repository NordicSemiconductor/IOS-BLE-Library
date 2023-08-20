// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOS-BLE-Library",
    platforms: [
        .iOS(.v13),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "iOS-BLE-Library",
            targets: ["iOS-BLE-Library"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/NickKibish/IOS-CoreBluetooth-Mock.git",
            branch: "main"
//            url: "https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock.git",
//            from: "0.16.1"
        ),
        .package(
            url: "https://github.com/NickKibish/CoreBluetoothMock-Collection.git",
            branch: "main"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "iOS-BLE-Library",
            dependencies: [
                .product(name: "CoreBluetoothMock", package: "IOS-CoreBluetooth-Mock"),
                .product(name: "CoreBluetoothMock-Collection", package: "CoreBluetoothMock-Collection")
            ]),
        .testTarget(
            name: "iOS-BLE-LibraryTests",
            dependencies: ["iOS-BLE-Library"]),
    ]
)
