//
//  File.swift
//
//
//  Created by Nick Kibysh on 25/04/2023.
//

import Combine
import CoreBluetoothMock
import Foundation

extension Publisher where Output == CBPeripheral, Failure == Error {
	func peripheral(_ fire: @escaping () -> Void) -> Publishers.Peripheral {
		Publishers.Peripheral(self, fire: fire)
	}
}

extension Publishers.Peripheral {
	var value: Output {
		get async throws {
			try await ContinuationSubscriber<Publishers.Peripheral>
				.withCheckedContinuation(self)
		}
	}
}

extension Publishers {
	public class Peripheral: ConnectablePublisher {
		public typealias Output = CBPeripheral
		public typealias Failure = Error

		private let inner: BaseConnectable<Output, Failure>

		init<PublisherType: Publisher>(
			_ publisher: PublisherType, fire: @escaping () -> Void
		) where Output == PublisherType.Output, Failure == PublisherType.Failure {
			self.inner = ClosureConnectablePublisher(upstream: publisher, fire: fire)
		}

		public func receive<S>(subscriber: S)
		where S: Subscriber, Failure == S.Failure, CBPeripheral == S.Input {
			inner.receive(subscriber: subscriber)
		}

		public func connect() -> Cancellable {
			return inner.connect()
		}
	}

	public class Service: ConnectablePublisher {
		public typealias Output = CBService
		public typealias Failure = Error

		private let inner: BaseConnectable<Output, Failure>

		init<PublisherType: Publisher>(
			_ publisher: PublisherType, fire: @escaping () -> Void
		) where Output == PublisherType.Output, Failure == PublisherType.Failure {
			self.inner = ClosureConnectablePublisher(upstream: publisher, fire: fire)
		}

		public func receive<S>(subscriber: S)
		where S: Subscriber, Failure == S.Failure, CBService == S.Input {
			inner.receive(subscriber: subscriber)
		}

		public func connect() -> Cancellable {
			return inner.connect()
		}
	}

}
