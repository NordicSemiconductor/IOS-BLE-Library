//
//  File.swift
//
//
//  Created by Nick Kibysh on 01/05/2023.
//

import Combine

extension Publishers {
	
    struct GuestList<Upstream, Guest: Equatable>: Publisher where Upstream: Publisher {
		typealias Output = Upstream.Output
		typealias Failure = Upstream.Failure

		private let list: [Guest]
		private let check: (Guest, Output) -> Bool
		private let upstream: Upstream

		init(upstream: Upstream, list: [Guest], check: @escaping (Guest, Output) -> Bool) {
			self.list = list
			self.check = check
			self.upstream = upstream
		}

		init(upstream: Upstream, list: [Guest]) where Guest == Output {
			self.list = list
			self.check = { g, o in g == o }
			self.upstream = upstream
		}

		init(upstream: Upstream, list: [Guest], keypath: KeyPath<Output, Guest>) {
			self.list = list
			self.check = { g, o in o[keyPath: keypath] == g }
			self.upstream = upstream
		}

		func receive<S>(subscriber: S)
		where S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
			upstream.subscribe(Inner(downstream: subscriber, list: list, check: check))
		}
	}
}

extension Publishers.GuestList {
	
    class Inner<Downstream>: Subscriber, Subscription where Downstream: Subscriber, Upstream.Output == Downstream.Input, Upstream.Failure == Downstream.Failure {
		typealias Input = Upstream.Output
		typealias Failure = Upstream.Failure

		private var list: [Guest]
		private var subscription: Subscription?
		private let check: (Guest, Upstream.Output) -> Bool
		private let downstream: Downstream
		private var demand: Subscribers.Demand = .unlimited

		init(downstream: Downstream, list: [Guest], check: @escaping (Guest, Input) -> Bool) {
			self.downstream = downstream
			self.list = list
			self.check = check
		}

		func receive(subscription: Subscription) {
			self.subscription = subscription
			downstream.receive(subscription: self)
		}

		func receive(_ input: Upstream.Output) -> Subscribers.Demand {
			for guest in list.enumerated() {
				if check(guest.element, input) {
					list.remove(at: guest.offset)
					demand = downstream.receive(input)
					break
				}
			}

			if list.isEmpty {
				downstream.receive(completion: .finished)
				cancel()
			}

			return demand
		}

		func receive(completion: Subscribers.Completion<Upstream.Failure>) {
			downstream.receive(completion: completion)
		}

		func request(_ demand: Subscribers.Demand) {
			self.demand = demand
			subscription?.request(demand)
		}

		func cancel() {
			subscription?.cancel()
		}

	}
}

extension Publisher {
	
    func guestList<Guest>(_ list: [Guest], check: @escaping (Guest, Output) -> Bool) -> Publishers.GuestList<Self, Guest> {
		Publishers.GuestList(upstream: self, list: list, check: check)
	}

	func guestList<Guest: Equatable>(_ list: [Guest]) -> Publishers.GuestList<Self, Guest> where Guest == Output {
		Publishers.GuestList(upstream: self, list: list)
	}

	func guestList<Guest: Equatable>(_ list: [Guest], keypath: KeyPath<Output, Guest>) -> Publishers.GuestList<Self, Guest> {
		Publishers.GuestList(upstream: self, list: list, keypath: keypath)
	}
}
