//
//  File.swift
//  
//
//  Created by Nick Kibysh on 07/04/2023.
//

import Foundation



/*
public final class BluetoothState {
    public enum State {
        init(cbState: CBManagerState) {
            switch cbState {
            case .unknown:
                self = .unknown
            case .resetting:
                self = .resetting
            case .unsupported:
                self = .unsupported
            case .unauthorized:
                self = .unauthorized
            case .poweredOff:
                self = .poweredOff
            case .poweredOn:
                self = .poweredOn
            }
        }

        case unknown
        case resetting
        case unsupported
        case unauthorized
        case poweredOff
        case poweredOn
    }
    
    public private (set) var state: State = .unknown
    private var iterators: [Iterator] = []
    
    func add(iterator: Iterator) {
        iterators.append(iterator)
    }
    
    func set(state: State) {
        self.state = state
    }
}

extension BluetoothState: AsyncSequence {
    nonisolated public func makeAsyncIterator() -> Iterator {
        let i = Iterator()
        
        return i
    }
    
    public typealias AsyncIterator = Iterator
    
    public typealias Element = State
    
    public struct Iterator {
        var continuation: CheckedContinuation<State?, Never>?
        var currentState: State?
    }
}

extension BluetoothState.Iterator: AsyncIteratorProtocol {
    mutating func execute(with state: BluetoothState.State) {
        if let continuation {
            continuation.resume(returning: state)
        } else {
            currentState = state
        }
    }
    
    public typealias Element = BluetoothState.State
    
    mutating public func next() async throws -> BluetoothState.State? {
        if let currentState {
            return currentState
        } else {
            return await withCheckedContinuation { c in
                self.continuation = c
            }
        }
    }
    
}
*/
