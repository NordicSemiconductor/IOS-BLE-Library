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
        .library(name: "iOS-BLE-Library", targets: ["iOS-BLE-Library"]),
        .library(name: "iOS-BLE-Library-Mock", targets: ["iOS-BLE-Library-Mock"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock.git",
            from: "0.17.0"
        ),
        .package(
            url: "https://github.com/NickKibish/CoreBluetoothMock-Collection.git",
            branch: "main"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "iOS-BLE-Library"),
        .target(
            name: "iOS-BLE-Library-Mock",
            dependencies: ["iOS-BLE-Library", .product(name: "CoreBluetoothMock", package: "IOS-CoreBluetooth-Mock")]
        ),
        .testTarget(
            name: "iOS-BLE-LibraryTests",
            dependencies: ["iOS-BLE-Library-Mock",
                           .product(name: "CoreBluetoothMock-Collection", package: "CoreBluetoothMock-Collection")
            ]),
    ]
)
