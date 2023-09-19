# ``iOS_BLE_Library/CentralManager``

## Topics

Loren ipsum 

Loren Ipsum 

## Channels

Channels are used to pass through data from the `CBCentralManagerDelegate` methods.
You can consider them as a reactive version of the `CBCentralManagerDelegate` methods.

In most cases, you will not need to use them directly, as `centralManager`'s methods return proper publishers.
However, if you need to handle the data in a different way (e.g. log all the events), you can subscribe to the channels directly. 

- ``stateChannel``
- ``isScanningChannel``
- ``scanResultsChannel``
- ``connectedPeripheralChannel``
- ``disconnectedPeripheralsChannel``
