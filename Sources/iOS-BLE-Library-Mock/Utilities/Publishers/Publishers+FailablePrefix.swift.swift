//
//  Publishers+FailablePrefix.swift
//
//
//  Created by Nick Kibysh on 22/08/2023.
//

import Combine
import Foundation

extension Publisher {
	func prefix<Other: Publisher>(
		untilUntilOutputOrCompletion publisher: Other
	) -> Publishers.PrefixUntilOutputOrCompletion<Self, Other> {
		return .init(upstream: self, other: publisher)
	}
}

extension Publishers {
	struct PrefixUntilOutputOrCompletion<Upstream: Publisher, Other: Publisher>: Publisher
	where Other.Failure == Upstream.Failure {

		public typealias Output = Upstream.Output
		public typealias Failure = Upstream.Failure

		public let upstream: Upstream
		public let other: Other

		public init(upstream: Upstream, other: Other) {
			self.upstream = upstream
			self.other = other
		}

		public func receive<Downstream: Subscriber>(subscriber: Downstream)
		where Downstream.Failure == Failure, Downstream.Input == Output {
			upstream.subscribe(Inner(downstream: subscriber, trigger: other))
		}
	}
}

#warning("Thread safety should be considered")
extension Publishers.PrefixUntilOutputOrCompletion {
	private final class Inner<Downstream: Subscriber>: Subscriber, Subscription
	where Downstream.Input == Upstream.Output, Downstream.Failure == Upstream.Failure {
		typealias Input = Upstream.Output
		typealias Failure = Upstream.Failure

		private struct Termination: Subscriber {

			let inner: Inner

			var combineIdentifier: CombineIdentifier {
				return inner.combineIdentifier
			}

			func receive(subscription: Subscription) {
				inner.terminationReceive(subscription: subscription)
			}

			func receive(_ input: Other.Output) -> Subscribers.Demand {
				return inner.terminationReceive(input)
			}

			func receive(completion: Subscribers.Completion<Other.Failure>) {
				inner.terminationReceive(completion: completion)
			}
		}

		private var subscription: Subscription?
		private var termination: Termination?
		private var terminationSubscription: Subscription?
		private let downstream: Downstream

		init(downstream: Downstream, trigger: Other) {
			self.downstream = downstream
			let termination = Termination(inner: self)
			self.termination = termination
			trigger.subscribe(termination)
		}

		func receive(subscription: Subscription) {
			self.subscription = subscription
			downstream.receive(subscription: self)
		}

		func receive(_ input: Input) -> Subscribers.Demand {
			return downstream.receive(input)
		}

		func receive(completion: Subscribers.Completion<Failure>) {
			terminationSubscription?.cancel()
			termination = nil
			subscription = nil
			downstream.receive(completion: completion)
		}

		func request(_ demand: Subscribers.Demand) {
			subscription?.request(demand)
		}

		func cancel() {
			subscription?.cancel()
			terminationSubscription?.cancel()
		}

		// MARK: - Private

		private func terminationReceive(subscription: Subscription) {
			terminationSubscription = subscription
			subscription.request(.max(1))
		}

		private func terminationReceive(_ input: Other.Output) -> Subscribers.Demand {
			terminate(.finished)
			return .none
		}

		private func terminationReceive(completion: Subscribers.Completion<Other.Failure>) {
			terminate(completion)
		}

		private func terminate(_ completion: Subscribers.Completion<Other.Failure>) {
			terminationSubscription?.cancel()
			self.subscription?.cancel()
			downstream.receive(completion: completion)
		}
	}
}
