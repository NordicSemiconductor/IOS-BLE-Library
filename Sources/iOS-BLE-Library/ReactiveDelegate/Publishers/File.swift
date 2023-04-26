//
//  File.swift
//  
//
//  Created by Nick Kibysh on 25/04/2023.
//

import Foundation
import Combine

public final class SingleResultPublisher<Upstream: Publisher>: Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    
    public let upstream: Upstream
    public let fire: () -> ()
    
    public init(upstream: Upstream, fire: @escaping () -> ()) {
        self.upstream = upstream
        self.fire = fire
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        upstream.subscribe(Inner<S>(downstream: subscriber))
    }
    
    public func connect() -> Cancellable {
        fatalError()
    }
}

extension SingleResultPublisher {
    class Inner<Downstream: Subscriber>: Subscriber {
        
        typealias Input = Downstream.Input
        typealias Failure = Downstream.Failure
        
        let downstream: Downstream
        
        init(downstream: Downstream) {
            self.downstream = downstream
        }
        
        func receive(subscription: Subscription) {
            downstream.receive(subscription: subscription)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            _ = downstream.receive(input)
            downstream.receive(completion: .finished)
            
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            downstream.receive(completion: completion)
        }
    }
}
