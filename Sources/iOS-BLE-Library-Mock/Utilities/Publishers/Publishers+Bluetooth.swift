//
//  File.swift
//
//
//  Created by Nick Kibysh on 05/05/2023.
//

import Combine
import Foundation

extension Publisher {
	func bluetooth(_ fire: @escaping () -> Void)
		-> Publishers.BluetoothPublisher<Output, Failure>
	{
		Publishers.BluetoothPublisher<Output, Failure>(self, fire: fire)
	}
}

extension Publishers {
    
    /**
     A publisher that is used for most of the Bluetooth operations.
     
     # Overview
     This publisher conforms to the `ConnectablePublisher` protocol because most of the Bluetooth operations have to be set up before they can be used.
     
	 It means that the publisher will not emit any values until it is connected. The connection is established by calling the `connect()` or `autoconnect()` methods.
	 To learn more about the `ConnectablePublisher` protocol, see [Apple's documentation](https://developer.apple.com/documentation/combine/connectablepublisher).
     
     ```swift
     let publisher = centralManager.scanForPeripherals(withServices: nil)
         .autoconnect()
         // chain of publishers
         .sink {
            // . . .
          }
         .store(in: &cancellables)
     ```
    */
	class BluetoothPublisher<Output, Failure: Error>: ConnectablePublisher {

		private let inner: BaseConnectable<Output, Failure>

		init<PublisherType: Publisher>(
			_ publisher: PublisherType, fire: @escaping () -> Void
		) where Output == PublisherType.Output, Failure == PublisherType.Failure {
			self.inner = ClosureConnectablePublisher(upstream: publisher, fire: fire)
		}

		public func receive<S>(subscriber: S)
		where S: Subscriber, Failure == S.Failure, Output == S.Input {
			inner.receive(subscriber: subscriber)
		}

		public func connect() -> Cancellable {
			return inner.connect()
		}
	}
}
