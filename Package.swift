// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "iOS-BLE-Library",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "iOS-BLE-Library", targets: ["iOS-BLE-Library"]),
        .library(name: "iOS-BLE-Library-Mock", targets: ["iOS-BLE-Library-Mock"]),
    ],
    dependencies: [
        .package(url: "https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock.git", from: "0.17.0"),
        .package(url: "https://github.com/NickKibish/CoreBluetoothMock-Collection.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/NordicPlayground/IOS-Common-Libraries", branch: "main"),
    ],
    targets: [
        .target(name: "iOS-BLE-Library"),
        .target(name: "iOS-BLE-Library-Mock", dependencies: ["iOS-BLE-Library", .product(name: "CoreBluetoothMock", package: "IOS-CoreBluetooth-Mock")]),
        .testTarget(name: "iOS-BLE-LibraryTests", dependencies: ["iOS-BLE-Library-Mock", .product(name: "CoreBluetoothMock-Collection", package: "CoreBluetoothMock-Collection")]),
    ]
)
