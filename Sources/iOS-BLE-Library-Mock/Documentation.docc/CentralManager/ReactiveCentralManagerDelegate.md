# ``iOS_BLE_Library/ReactiveCentralManagerDelegate``

Implementation of the `CBCentralManagerDelegate`.

`ReactiveCentralManagerDelegate` is a class that implements the `CBCentralManagerDelegate` and is an essential part of the ``CentralManager`` class.

It brings a reactive programming approach, utilizing Combine publishers to seamlessly handle Bluetooth events and data. 
This class allows to monitor and respond to events such as peripheral connection, disconnection, and scanning for peripherals.

It has all needed publishers that are used for handling Bluetooth events and data. 

## Override

It's possible to override the default implementation of the `ReactiveCentralManagerDelegate` by creating a new class that inherits from `ReactiveCentralManagerDelegate` and overriding the needed methods. 

However, it's important to call the `super` implementation of the method, otherwise it will break the `CentralManager` functionality.
