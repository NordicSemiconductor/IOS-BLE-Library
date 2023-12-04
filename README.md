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
        .package(url: "https://github.com/NordicSemiconductor/IOS-BLE-Library.git", from: "0.1.3"),
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
pod 'iOS-BLE-Library', '~> 0.1.3'
```

or 
```ruby
pod 'iOS-BLE-Library-Mock', '~> 0.1.3'
```

# Use At Your Own Risk (Currently)


As of this writing, we are not recommending this library for external use. It is used by both our Private and Public / Open-Source apps, hence the need to make it public as well. But for now we haven't settled on the API - we're still learning from all of Apple's new technologies such as Actors and Async / Await, therefore, it is likely big changes might be required as we move forward. 

# Documentation & Examples
Please check the [Documentation Page](https://nordicsemiconductor.github.io/IOS-BLE-Library/documentation/ios_ble_library/) to start using the library.

Also you can check [iOS-nRF-Toolbox](https://github.com/NordicSemiconductor/IOS-nRF-Toolbox/tree/develop) to find more examples.

