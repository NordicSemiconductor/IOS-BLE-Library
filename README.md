![Platforms](https://img.shields.io/badge/platforms-iOS%20|%20macOS-333333.svg)

# iOS-BLE-Library

![Bluetooth Logo](https://img2.freepng.es/20180203/rrw/kisspng-bluetooth-low-energy-wireless-speaker-headset-bluetooth-png-transparent-picture-5a756c996d8f82.9161960415176449534488.jpg)

An in-development Bluetooth Low Energy Library by Nordic Semiconductor to interact with the ![CoreBluetooth API](https://developer.apple.com/documentation/corebluetooth), which is not complicated, but requires writing a similar amount of boilerplate around it to interact with it from the app's logic or UI. So, instead of copying / pasting the same code and adapting it for each particular app's use, we're striving to build a modern API that we can use across all of our apps.

# Use At Your Own Risk (Currently)

As of this writing, we are not recommending this library for external use. It is used by both our Private and Public / Open-Source apps, hence the need to make it public as well. But for now we haven't settled on the API - we're still learning from all of Apple's new technologies such as Actors and Async / Await, therefore, it is likely big changes might be required as we move forward. 
