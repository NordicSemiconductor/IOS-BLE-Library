// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "iOS-BLE-Library",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "iOS-BLE-Library", targets: ["iOS-BLE-Library"]),
        .library(name: "iOS-BLE-Library-Mock", targets: ["iOS-BLE-Library-Mock"]),
    ],
    dependencies: [
        .package(url: "https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock.git",
                 .upToNextMajor(from: "1.0.0")
        ),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(name: "iOS-BLE-Library"),
        .target(name: "iOS-BLE-Library-Mock", dependencies: ["iOS-BLE-Library", .product(name: "CoreBluetoothMock", package: "IOS-CoreBluetooth-Mock")])
    ]
)
