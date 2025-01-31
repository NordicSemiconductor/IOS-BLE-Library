//
//  File.swift
//
//
//  Created by Nick Kibysh on 05/05/2023.
//

import Combine
import Foundation

class ContinuationSubscriber<Upstream: Publisher>: Subscriber {

	typealias Input = Upstream.Output
	typealias Failure = Upstream.Failure

	private let continuation: CheckedContinuation<Input, Error>
	private var state: State = .waitingForSubscription
	private var lock = NSLock()
	private var subscription: Subscription?

	enum State {
		case waitingForSubscription
		case receivedSubscription
		case terminated
	}

	init(continuation: CheckedContinuation<Input, Error>) {
		self.continuation = continuation
	}

	func receive(subscription: Subscription) {
		lock.lock()
		guard case .waitingForSubscription = state else {
			lock.unlock()
			return
		}

		self.state = .receivedSubscription
		self.subscription = subscription
		lock.unlock()

		subscription.request(.max(1))
	}

	func receive(_ input: Upstream.Output) -> Subscribers.Demand {
		lock.lock()
		guard case .receivedSubscription = state else {
			lock.unlock()
			return .none
		}
		self.state = .terminated
		continuation.resume(returning: input)

		self.subscription?.cancel()
		lock.unlock()

		return .none
	}

	func receive(completion: Subscribers.Completion<Upstream.Failure>) {
		lock.lock()
		guard case .receivedSubscription = state else {
			lock.unlock()
			return
		}

		self.state = .terminated

		switch completion {
		case .finished:
			break
		case .failure(let failure):
			continuation.resume(throwing: failure)
		}
		lock.unlock()
	}
}

extension ContinuationSubscriber {
	
    static func withCheckedContinuation(_ upstream: Upstream) async throws -> Input where Upstream.Output == Input, Upstream.Failure == Failure {
            
		try await withCheckedThrowingContinuation { c in
			upstream.subscribe(ContinuationSubscriber(continuation: c))
		}
	}
}
