//
//  File.swift
//  
//
//  Created by Nick Kibysh on 05/05/2023.
//

import Foundation
import Combine

extension Publisher {
    func bluetooth(_ fire: @escaping () -> ()) -> Publishers.BluetoothPublisher<Output, Failure> {
        Publishers.BluetoothPublisher<Output, Failure >(self, fire: fire)
    }
}

extension Publishers {
    public class BluetoothPublisher<Output, Failure: Error>: ConnectablePublisher {
        
        private let inner: BaseConnectable<Output, Failure>
        
        init<PublisherType: Publisher>(_ publisher: PublisherType, fire: @escaping () -> ()) where Output == PublisherType.Output, Failure == PublisherType.Failure {
            self.inner = ClosureConnectablePublisher(upstream: publisher, fire: fire)
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            inner.receive(subscriber: subscriber)
        }
        
        public func connect() -> Cancellable {
            return inner.connect()
        }
    }
}
