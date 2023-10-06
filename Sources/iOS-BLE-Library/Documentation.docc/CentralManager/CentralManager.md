# ``iOS_BLE_Library/CentralManager``

### Create a Central Manager

``CentralManager`` is merely a wrapper around `CBCentralManager` with an instance of it inside.

The new instance of `CBCentralManager` can be created during initialization using ``init(centralManagerDelegate:queue:options:)``, or an existing instance can be passed using ``init(centralManager:)``.

If you pass a central manager inside ``init(centralManager:)``, it should already have a delegate set. The delegate should be an instance of ``ReactiveCentralManagerDelegate``; otherwise, an error will be thrown.

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

### Initializers

- ``init(centralManagerDelegate:queue:)``
- ``init(centralManager:)``

### Instance Properties

- ``centralManager``
- ``centralManagerDelegate``

### Scan

- ``scanForPeripherals(withServices:)``
- ``stopScan()``
- ``retrievePeripherals(withIdentifiers:)``

### Connection

- ``connect(_:options:)``
- ``cancelPeripheralConnection(_:)``
- ``retrieveConnectedPeripherals(withServices:)``

### Channels

- ``stateChannel``
- ``isScanningChannel``
- ``scanResultsChannel``
- ``connectedPeripheralChannel``
- ``disconnectedPeripheralsChannel``
