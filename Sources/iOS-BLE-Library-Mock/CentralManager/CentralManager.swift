//
//  File.swift
//
//
//  Created by Nick Kibysh on 18/04/2023.
//

import Combine
import CoreBluetoothMock
import Foundation

extension CentralManager {
	public enum Err: Error {
		case wrongManager
		case badState(CBManagerState)
		case unknownError

		public var localizedDescription: String {
			switch self {
			case .wrongManager:
				return
					"Incorrect manager instance provided. Delegate must be of type ReactiveCentralManagerDelegate."
			case .badState(let state):
				return "Bad state: \(state)."
			case .unknownError:
				return "An unknown error occurred."
			}
		}
	}
}

private class Observer: NSObject {
	@objc dynamic private weak var cm: CBCentralManager?
	private weak var publisher: CurrentValueSubject<Bool, Never>?
	private var observation: NSKeyValueObservation?

	init(cm: CBCentralManager, publisher: CurrentValueSubject<Bool, Never>) {
		self.cm = cm
		self.publisher = publisher
		super.init()
	}

	func setup() {
		observation = observe(
			\.cm?.isScanning,
			options: [.old, .new],
			changeHandler: { _, change in

				change.newValue?.flatMap { [weak self] new in
					self?.publisher?.send(new)
				}
			}
		)
	}
}

/// A Custom Central Manager class.
///
/// It wraps the standard CBCentralManager and has similar API. However, instead of using delegate, it uses publishers, thus bringing the reactive programming paradigm to the CoreBluetooth framework.
public class CentralManager {
	private let isScanningSubject = CurrentValueSubject<Bool, Never>(false)
	private let killSwitchSubject = PassthroughSubject<Void, Never>()
	private lazy var observer = Observer(cm: centralManager, publisher: isScanningSubject)

	/// The underlying CBCentralManager instance.
	public let centralManager: CBCentralManager

	/// The reactive delegate for the ``centralManager``.
	public let centralManagerDelegate: ReactiveCentralManagerDelegate

	/// Initializes a new instance of `CentralManager`.
	/// - Parameters:
	///   - centralManagerDelegate: The delegate for the reactive central manager. Default is `ReactiveCentralManagerDelegate()`.
	///   - queue: The queue to perform operations on. Default is the main queue.
	public init(
		centralManagerDelegate: ReactiveCentralManagerDelegate =
			ReactiveCentralManagerDelegate(), queue: DispatchQueue = .main,
		options: [String: Any]? = nil
	) {
		self.centralManagerDelegate = centralManagerDelegate
		self.centralManager = CBMCentralManagerFactory.instance(
			delegate: centralManagerDelegate, queue: queue)
		observer.setup()
	}

	/// Initializes a new instance of `CentralManager` with an existing CBCentralManager instance.
	/// - Parameter centralManager: An existing CBCentralManager instance.
	/// - Throws: An error if the provided manager's delegate is not of type `ReactiveCentralManagerDelegate`.
	public init(centralManager: CBCentralManager) throws {
		guard
			let reactiveDelegate = centralManager.delegate
				as? ReactiveCentralManagerDelegate
		else {
			throw Err.wrongManager
		}

		self.centralManager = centralManager
		self.centralManagerDelegate = reactiveDelegate

		observer.setup()
	}
}

// MARK: Establishing or Canceling Connections with Peripherals
extension CentralManager {
	/// Establishes a connection with the specified peripheral.
	/// - Parameters:
	///   - peripheral: The peripheral to connect to.
	///   - options: Optional connection options.
	/// - Returns: A publisher that emits the connected peripheral on successful connection.
	///            The publisher does not finish until the peripheral is successfully connected.
	///            If the peripheral was disconnected successfully, the publisher finishes without error.
	///            If the connection was unsuccessful or disconnection returns an error (e.g., peripheral disconnected unexpectedly),
	///            the publisher finishes with an error.
	///
	/// Use ``CentralManager/connect(_:options:)`` to connect to a peripheral.
	///    The returned publisher will emit the connected peripheral or an error if the connection fails.
	///    The publisher will not complete until the peripheral is disconnected.
	///    If the connection fails, or the peripheral is unexpectedly disconnected, the publisher will fail with an error.
	///
	///    ```swift
	///    centralManager.connect(peripheral)
	///        .sink { completion in
	///            switch completion {
	///            case .finished:
	///                print("Peripheral disconnected successfully")
	///            case .failure(let error):
	///                print("Error: \(error)")
	///            }
	///        } receiveValue: { peripheral in
	///            print("Peripheral connected: \(peripheral)")
	///        }
	///        .store(in: &cancellables)
	///    ```
	public func connect(_ peripheral: CBPeripheral, options: [String: Any]? = nil)
		-> AnyPublisher<CBPeripheral, Error>
	{
		let killSwitch = self.disconnectedPeripheralsChannel.tryFirst(where: { p in
			if let e = p.1 {
				throw e
			}
			return p.0.identifier == peripheral.identifier
		})

		return self.connectedPeripheralChannel
			.filter { $0.0.identifier == peripheral.identifier }
			.tryMap { peripheral, error in
				if let error {
					throw error
				}

				return peripheral
			}
			.prefix(untilUntilOutputOrCompletion: killSwitch)
			.bluetooth {
				self.centralManager.connect(peripheral, options: options)
			}
			.autoconnect()
			.eraseToAnyPublisher()
	}

	/// Cancels the connection with the specified peripheral.
	/// - Parameter peripheral: The peripheral to disconnect from.
	/// - Returns: A publisher that emits the disconnected peripheral.
	public func cancelPeripheralConnection(_ peripheral: CBPeripheral) -> AnyPublisher<
		CBPeripheral, Error
	> {
		return self.disconnectedPeripheralsChannel
			.tryFilter { r in
				guard r.0.identifier == peripheral.identifier else {
					return false
				}

				if let e = r.1 {
					throw e
				} else {
					return true
				}
			}
			.map { $0.0 }
			.first()
			.bluetooth {
				self.centralManager.cancelPeripheralConnection(peripheral)
			}
			.autoconnect()
			.eraseToAnyPublisher()
	}
}

// MARK: Retrieving Lists of Peripherals
extension CentralManager {
	#warning("check `connect` method")
	/// Returns a list of the peripherals connected to the system whose
	/// services match a given set of criteria.
	///
	/// The list of connected peripherals can include those that other apps
	/// have connected. You need to connect these peripherals locally using
	/// the `connect(_:options:)` method before using them.
	/// - Parameter serviceUUIDs: A list of service UUIDs, represented by
	///                           `CBUUID` objects.
	/// - Returns: A list of the peripherals that are currently connected
	///            to the system and that contain any of the services
	///            specified in the `serviceUUID` parameter.
	public func retrieveConnectedPeripherals(withServices identifiers: [CBUUID]) -> [CBPeripheral] {
		centralManager.retrieveConnectedPeripherals(withServices: identifiers)
	}

	/// Returns a list of known peripherals by their identifiers.
	/// - Parameter identifiers: A list of peripheral identifiers
	///                          (represented by `NSUUID` objects) from which
	///                          ``CBPeripheral`` objects can be retrieved.
	/// - Returns: A list of peripherals that the central manager is able
	///            to match to the provided identifiers.
	public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral] {
		centralManager.retrievePeripherals(withIdentifiers: identifiers)
	}
}

// MARK: Scanning or Stopping Scans of Peripherals
extension CentralManager {
	#warning("Question: Should we throw an error if the scan is already running?")
	/// Initiates a scan for peripherals with the specified services.
	///
	/// Calling this method stops an ongoing scan if it is already running and finishes the publisher returned by ``scanForPeripherals(withServices:)``.
	///
	/// - Parameters:
	///   - services: The services to scan for.
	///   - options: A dictionary to customize the scan, such as specifying whether duplicate results should be reported.
	/// - Returns: A publisher that emits scan results or an error.
	public func scanForPeripherals(withServices services: [CBUUID]?, options: [String: Any]? = nil) -> AnyPublisher<ScanResult, Error> {
		stopScan()
		return centralManagerDelegate.stateSubject
			.tryFirst { state in
				guard let determined = state.ready else { return false }

				guard determined else { throw Err.badState(state) }
				return true
			}
			.flatMap { _ in
				// TODO: Check for mmemory leaks
				return self.centralManagerDelegate.scanResultSubject
					.setFailureType(to: Error.self)
			}
			.map { a in
				return a
			}
			.prefix(untilOutputFrom: killSwitchSubject)
			.mapError { [weak self] e in
				self?.stopScan()
				return e
			}
			.bluetooth {
				self.centralManager.scanForPeripherals(
					withServices: services, options: options)
			}
			.autoconnect()
			.eraseToAnyPublisher()
	}

	/// Stops an ongoing scan for peripherals.
	/// Calling this method finishes the publisher returned by ``scanForPeripherals(withServices:)``.
	public func stopScan() {
		centralManager.stopScan()
		killSwitchSubject.send(())
	}
}

// MARK: Channels
extension CentralManager {
	/// A publisher that emits the state of the central manager.
	public var stateChannel: AnyPublisher<CBManagerState, Never> {
		centralManagerDelegate
			.stateSubject
			.eraseToAnyPublisher()
	}

	/// A publisher that emits the scanning state.
	public var isScanningChannel: AnyPublisher<Bool, Never> {
		isScanningSubject
			.eraseToAnyPublisher()
	}

	/// A publisher that emits scan results.
	public var scanResultsChannel: AnyPublisher<ScanResult, Never> {
		centralManagerDelegate.scanResultSubject
			.eraseToAnyPublisher()
	}

	/// A publisher that emits connected peripherals along with errors.
	public var connectedPeripheralChannel: AnyPublisher<(CBPeripheral, Error?), Never> {
		centralManagerDelegate.connectedPeripheralSubject
			.eraseToAnyPublisher()
	}

	/// A publisher that emits disconnected peripherals along with errors.
	public var disconnectedPeripheralsChannel: AnyPublisher<(CBPeripheral, Error?), Never> {
		centralManagerDelegate.disconnectedPeripheralsSubject
			.eraseToAnyPublisher()
	}
}
