//
//  File.swift
//  
//
//  Created by Nick Kibysh on 05/05/2023.
//

import Foundation
import Combine

class ContinuationSubscriber<Upstream: Publisher>: Subscriber {
    
    typealias Input = Upstream.Output
    typealias Failure = Upstream.Failure
    
    private let continuation: CheckedContinuation<Input, Error>
    
    init(continuation: CheckedContinuation<Input, Error>) {
        self.continuation = continuation
    }
    
    func receive(subscription: Subscription) {
        subscription.request(.max(1))
    }
    
    func receive(_ input: Upstream.Output) -> Subscribers.Demand {
        continuation.resume(returning: input)
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Upstream.Failure>) {
        switch completion {
        case .finished:
            break
        case .failure(let failure):
            continuation.resume(throwing: failure)
        }
    }
}


extension ContinuationSubscriber {
    static func withCheckedContinuation<Upstream: Publisher>(_ upstream: Upstream) async throws -> Input where Upstream.Output == Input, Upstream.Failure == Failure {
        
        try await withCheckedThrowingContinuation { c in
            upstream.subscribe(ContinuationSubscriber(continuation: c))
        }
    }
}
