# ``iOS_BLE_Library/CentralManager``

### Connection 

Use ``CentralManager/connect(_:options:)`` to connect to a peripheral.
The returned publisher will emit the connected peripheral or an error if the connection fails.
The publisher will not complete until the peripheral is disconnected. 
If the connection fails, or the peripheral is unexpectedly disconnected, the publisher will fail with an error.

> The publisher returned by ``CentralManager/connect(_:options:)`` is a `ConnectablePublisher`. Therefore, you need to call `connect()` or `autoconnect()` to initiate the connection process.

```swift
centralManager.connect(peripheral)
    .autoconnect()
    .sink { completion in
        switch completion {
        case .finished:
            print("Peripheral disconnected successfully")
        case .failure(let error):
            print("Error: \(error)")
        }
    } receiveValue: { peripheral in
        print("Peripheral connected: \(peripheral)")
    }
    .store(in: &cancellables)
```

### Channels

Channels are used to pass through data from the `CBCentralManagerDelegate` methods.
You can consider them as a reactive version of the `CBCentralManagerDelegate` methods.

In most cases, you will not need to use them directly, as `centralManager`'s methods return proper publishers. However, if you need to handle the data differently (e.g., log all the events), you can subscribe to the channels directly.

All channels have `Never` as their failure type because they never fail. Some channels, like `CentralManager/connectedPeripheralChannel` or `CentralManager/disconnectedPeripheralsChannel`, send tuples with the peripheral and the error, allowing you to handle errors if needed. Despite this, the failure type remains `Never`, so it will not complete even if an error occurs during the connection or disconnection of the peripheral.

```swift
centralManager.connectedPeripheralChannel
    .sink { peripheral, error in
        if let error = error {
            print("Error: \(error)")
        } else {
            print("New peripheral connected: \(peripheral)"
        }
    }
    .store(in: &cancellables)
```

## Topics

### Channels

- ``stateChannel``
- ``isScanningChannel``
- ``scanResultsChannel``
- ``connectedPeripheralChannel``
- ``disconnectedPeripheralsChannel``
