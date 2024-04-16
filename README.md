![Platforms](https://img.shields.io/badge/platforms-iOS%20|%20macOS-333333.svg)

# iOS-BLE-Library

This library is a wrapper around the CoreBluetooth framework which provides a modern async API based on Combine Framework. 

# Library Versions

This package contains two versions of the library: 
* `iOS-BLE-Library` - the library that uses the native CoreBluetooth API.
* `iOS-BLE-Library-Mock` - the library that uses the [CoreBluetoothMock](https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock) API.

# Installation
## Swift Package Manager
The library can be installed using Swift Package Manager.

You can choose between two versions of the library: 
![`iOS-BLE-Library`](res/Screenshot-1.png)

Or you can add it as a dependency to your library:
```swift

let package = Package(
    /// . . .
    dependencies: [
        // Set the link to the library and choose the version
        .package(url: "https://github.com/NordicSemiconductor/IOS-BLE-Library.git", from: "0.3.1"),
    ],
    targets: [
        .target(
            name: "MyLib",
            dependencies: [
                // You can use "native" CoreBluetooth API
                .product(name: "iOS-BLE-Library", package: "iOS-BLE-Library")
            ]
        ),
        .testTarget(
            name: "MyLibTests",
            dependencies: [
                "MyLib",
                // Or you can use the CoreBluetoothMock API
                .product(name: "iOS-BLE-Library-Mock", package: "iOS-BLE-Library")
            ]
        ),
    ]
)
```

## CocoaPods
The library can be installed using CocoaPods.

Add the following line to your Podfile:
```ruby
pod 'IOS-BLE-Library', '~> 0.3.1'
```

or 
```ruby
pod 'IOS-BLE-Library-Mock', '~> 0.3.1'
```

# Documentation & Examples
Please check the [Documentation Page](https://nordicsemiconductor.github.io/IOS-BLE-Library/documentation/ios_ble_library/) to start using the library.

Also you can check [iOS-nRF-Toolbox](https://github.com/NordicSemiconductor/IOS-nRF-Toolbox/tree/develop) to find more examples.

