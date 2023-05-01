//
//  File.swift
//  
//
//  Created by Nick Kibysh on 25/04/2023.
//

import Foundation
import Combine
import CoreBluetooth

private class BasePublisher<Output, Failure: Error>: ConnectablePublisher {
    func connect() -> Cancellable {
        fatalError()
    }
    
    func receive<Downstream: Subscriber>(subscriber: Downstream)
        where Failure == Downstream.Failure, Output == Downstream.Input {
        fatalError()
    }
}

private class AutoconnectablePublisher<Upstream: Publisher>: BasePublisher<Upstream.Output, Upstream.Failure>  {
    typealias Output = Upstream.Output
    typealias Failure = Upstream.Failure
    
    let upstream: Upstream
    let fire: () -> ()
    let onCancel: (() -> ())?
    
    init(upstream: Upstream, fire: @escaping () -> (), onCancel: (() -> ())? = nil) {
        self.upstream = upstream
        self.fire = fire
        self.onCancel = onCancel
    }
    
    override func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        upstream.subscribe(subscriber)
    }
    
    override func connect() -> Cancellable {
        fire()
        return Cancelator(onCancel: onCancel)
    }
}

extension AutoconnectablePublisher {
    struct Cancelator: Cancellable {
        let onCancel: (() -> ())?
        
        func cancel() {
            onCancel?()
        }
    }
}

extension Publisher where Output == CBPeripheral, Failure == Error {
    func peripheral(_ fire: @escaping () -> ()) -> Publishers.Peripheral {
        Publishers.Peripheral(self, fire: fire)
    }
}

extension Publisher where Failure == Error {
    func btPublisher(_ fire: @escaping () -> ()) -> Publishers.BluetoothPublisher<Output> {
        Publishers.BluetoothPublisher<Output>(self, fire: fire)
    }
}

extension Publishers {
    public class BluetoothPublisher<Output>: ConnectablePublisher {
        public typealias Failure = Error
        
        private let inner: BasePublisher<Output, Failure>
        
        init<PublisherType: Publisher>(_ publisher: PublisherType, fire: @escaping () -> ()) where Output == PublisherType.Output, Failure == PublisherType.Failure {
            self.inner = AutoconnectablePublisher(upstream: publisher, fire: fire)
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            inner.receive(subscriber: subscriber)
        }
        
        public func connect() -> Cancellable {
            return inner.connect()
        }
    }
    
    public class Peripheral: ConnectablePublisher {
        public typealias Output = CBPeripheral
        public typealias Failure = Error
        
        private let inner: BasePublisher<Output, Failure>
        
        init<PublisherType: Publisher>(_ publisher: PublisherType, fire: @escaping () -> ()) where Output == PublisherType.Output, Failure == PublisherType.Failure {
            self.inner = AutoconnectablePublisher(upstream: publisher, fire: fire)
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, CBPeripheral == S.Input {
            inner.receive(subscriber: subscriber)
        }
        
        public func connect() -> Cancellable {
            return inner.connect()
        }
    }
    
    public class Service: ConnectablePublisher {
        public typealias Output = CBService
        public typealias Failure = Error
        
        private let inner: BasePublisher<Output, Failure>
        
        init<PublisherType: Publisher>(_ publisher: PublisherType, fire: @escaping () -> ()) where Output == PublisherType.Output, Failure == PublisherType.Failure {
            self.inner = AutoconnectablePublisher(upstream: publisher, fire: fire)
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, CBService == S.Input {
            inner.receive(subscriber: subscriber)
        }
        
        public func connect() -> Cancellable {
            return inner.connect()
        }
    }
    
}
