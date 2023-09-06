//
//  File.swift
//
//
//  Created by Nick Kibysh on 05/05/2023.
//

import Combine
import Foundation

class BaseConnectable<Output, Failure: Error>: ConnectablePublisher {
	func connect() -> Cancellable {
		fatalError()
	}

	func receive<Downstream: Subscriber>(subscriber: Downstream)
	where Failure == Downstream.Failure, Output == Downstream.Input {
		fatalError()
	}
}

class ClosureConnectablePublisher<Upstream: Publisher>: BaseConnectable<
	Upstream.Output, Upstream.Failure
>
{
	typealias Output = Upstream.Output
	typealias Failure = Upstream.Failure

	let upstream: Upstream
	let fire: () -> Void
	let onCancel: (() -> Void)?

	init(upstream: Upstream, fire: @escaping () -> Void, onCancel: (() -> Void)? = nil) {
		self.upstream = upstream
		self.fire = fire
		self.onCancel = onCancel
	}

	override func receive<S>(subscriber: S)
	where S: Subscriber, Failure == S.Failure, Output == S.Input {
		upstream.subscribe(subscriber)
	}

	override func connect() -> Cancellable {
		fire()
		return Cancelator(onCancel: onCancel)
	}
}

extension ClosureConnectablePublisher {
	struct Cancelator: Cancellable {
		let onCancel: (() -> Void)?

		func cancel() {
			onCancel?()
		}
	}
}
