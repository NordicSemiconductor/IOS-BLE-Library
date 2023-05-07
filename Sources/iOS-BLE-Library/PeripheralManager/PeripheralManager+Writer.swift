//
//  File.swift
//  
//
//  Created by Nick Kibysh on 07/05/2023.
//

import Foundation
import Combine
import CoreBluetoothMock

extension PeripheralManager {
    class Writer {
        let writtenEventsPublisher: AnyPublisher<(CBCharacteristic, Swift.Error?), Never>
        let peripheral: CBPeripheral
        
        let queue = OperationQueue()
        
        init(writtenEventsPublisher: AnyPublisher<(CBCharacteristic, Swift.Error?), Never>, peripheral: CBPeripheral) {
            self.writtenEventsPublisher = writtenEventsPublisher
            self.peripheral = peripheral
            
            queue.maxConcurrentOperationCount = 1
        }
    }
}

extension PeripheralManager.Writer {
    func write(_ value: Data, to characteristic: CBCharacteristic) -> Future<Void, Swift.Error> {
        let operation = WriteOperation(data: value,
                                       writtenEventsPublisher: writtenEventsPublisher,
                                       characteristic: characteristic,
                                       peripheral: peripheral)
        
        queue.addOperation(operation)
        
        return operation.future
    }
}

private class WriteOperation: Operation {
    
    private enum State: String {
        case ready, executing, finished
        
        var keyPath: String {
            "is\(rawValue.capitalized)"
        }
    }
    
    
    let writtenEventsPublisher: AnyPublisher<(CBCharacteristic, Swift.Error?), Never>
    let characteristic: CBCharacteristic
    let peripheral: CBPeripheral
    let data: Data
    
    private var cancelable: AnyCancellable?
    private var promise: ((Result<Void, Swift.Error>) -> Void)!
    private var state: State = .ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    init(data: Data, writtenEventsPublisher: AnyPublisher<(CBCharacteristic, Swift.Error?), Never>, characteristic: CBCharacteristic, peripheral: CBPeripheral) {
        self.data = data
        self.writtenEventsPublisher = writtenEventsPublisher
        self.characteristic = characteristic
        self.peripheral = peripheral
    }
    
    override var isExecuting: Bool {
        state == .executing
    }
    
    override var isFinished: Bool {
        state == .finished
    }
    
    var future: Future<Void, Swift.Error> {
        Future { [unowned self] promise in
            self.promise = promise
        }
    }
    
    override func main() {
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        
        self.cancelable = writtenEventsPublisher.share()
            .filter { $0.0.uuid == self.characteristic.uuid }
            .first()
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    self.promise(.success(()))
                case .failure(let e):
                    self.promise(.failure(e))
                }
                self.state = .finished
            } receiveValue: { _ in
                
            }
        
        state = .executing
        main()
    }
    
    override func cancel() {
        cancelable?.cancel()
    }
    
    override var isAsynchronous: Bool {
        true
    }
}
