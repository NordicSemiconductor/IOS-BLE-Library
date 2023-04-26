//
//  File.swift
//  
//
//  Created by Nick Kibysh on 25/04/2023.
//

import Foundation
import Combine
import CoreBluetooth

private class BasePublisher<Output, Failure: Error>: Publisher {
    func receive<Downstream: Subscriber>(subscriber: Downstream)
        where Failure == Downstream.Failure, Output == Downstream.Input {
        fatalError()
    }
}

private class SingleResultPublisher<Upstream: Publisher>: BasePublisher<Upstream.Output, Upstream.Failure>  {
    typealias Output = Upstream.Output
    typealias Failure = Upstream.Failure
    
    let upstream: Upstream
    
    init(upstream: Upstream) {
        self.upstream = upstream
    }
    
    override func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        upstream.subscribe(subscriber)
    }
}

extension Publisher where Output == CBPeripheral, Failure == Error {
    func peripheral(_ fire: @escaping () -> ()) -> Publishers.Peripheral {
        Publishers.Peripheral(self, fire: fire)
    }
}

extension Publishers {
    
    public class Peripheral: ConnectablePublisher {
        public typealias Output = CBPeripheral
        public typealias Failure = Error
        
        private let single: BasePublisher<Output, Failure>
        private let fire: () -> ()
        
        init<PublisherType: Publisher>(_ publisher: PublisherType, fire: @escaping () -> ()) where Output == PublisherType.Output, Failure == PublisherType.Failure {
            self.single = SingleResultPublisher(upstream: publisher)
            self.fire = fire
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, CBPeripheral == S.Input {
            single.receive(subscriber: subscriber)
        }
        
        public func connect() -> Cancellable {
            fire()
            return Executor()
        }
    }
    
}

extension Publishers.Peripheral {
    struct Executor: Cancellable {
        func cancel() {
            
        }
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
