![Platforms](https://img.shields.io/badge/platforms-iOS%20|%20macOS-333333.svg)

# iOS-BLE-Library

This library is a wrapper around the CoreBluetooth framework which provides a modern async API based on Combine Framework. 

# Library Versions

This package contains two versions of the library:
* `iOS-BLE-Library` - the library that uses the native CoreBluetooth API.
* `iOS-BLE-Library-Mock` - the library that uses the [CoreBluetoothMock](https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock) API.

## Code Generation System

**TLDR:** Run the next command to copy files
```bash
python3 code_gen/code_gen.py Sources/
```

The Mock version is automatically generated from the main library using a Python-based code generation system. This ensures both versions stay perfectly synchronized without maintaining duplicate codebases.

### How it Works

The generation process is handled by `code_gen/code_gen.py`:

```bash
python3 code_gen/code_gen.py Sources/
```

#### Generation Steps:

1. **Clone Sources**: The script locates `Sources/iOS-BLE-Library` and clones it into `Sources/iOS-BLE-Library-Mock`, recreating the full directory tree and overwriting existing files to ensure the mock target always mirrors the latest real library sources.

2. **Add Mock-Specific Files**: Additional files from `code_gen/additional_files/` (like `Alias.swift`) are copied into the mock tree. These provide CoreBluetoothMock typealiases that keep the public API identical between versions.

3. **Code Replacement**: The script walks through every `.swift` file in the cloned mock target, searching for regions delimited by special markers:
   ```swift
   //CG_REPLACE
   import CoreBluetooth
   //CG_WITH
   /*
   import CoreBluetoothMock
   */
   //CG_END
   ```

   It comments out the "real" CoreBluetooth block and uncomments the mock implementation block, effectively swapping CoreBluetooth imports and related code with CoreBluetoothMock equivalents.

#### Result

After generation, `Sources/iOS-BLE-Library-Mock` is code-identical to the original except for the swapped regions plus alias helpers, giving you a build that links against CoreBluetoothMock without hand-maintaining two diverging codebases.

### For Contributors

When adding new functionality:
- Only modify files in `Sources/iOS-BLE-Library/`
- Use the code generation markers when Core Bluetooth API usage differs between real and mock implementations
- Run the generation script to update the Mock version
- Both targets will be automatically kept in sync

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
pod 'IOS-BLE-Library', '~> 0.3.2'
```

or 
```ruby
pod 'IOS-BLE-Library-Mock', '~> 0.3.2'
```

# Documentation & Examples
Please check the [Documentation Page](https://nordicsemiconductor.github.io/IOS-BLE-Library/documentation/ios_ble_library/) to start using the library.

Also you can check [iOS-nRF-Toolbox](https://github.com/NordicSemiconductor/IOS-nRF-Toolbox/tree/develop) to find more examples.

