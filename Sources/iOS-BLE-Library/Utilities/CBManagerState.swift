//
//  CBManagerState.swift
//
//
//  Created by Dinesh Harjani on 23/8/22.
//

//CG_REPLACE
import CoreBluetooth
//CG_WITH
/*
import CoreBluetoothMock
*/
//CG_END
import Foundation

// MARK: - CBManagerState

@available(iOS 10.0, *)
@available(macOS 10.13, *)
extension CBManagerState: CustomDebugStringConvertible, CustomStringConvertible {

	public var debugDescription: String {
		return description
	}

	public var description: String {
		switch self {
		case .poweredOff:
			return "poweredOff"
		case .poweredOn:
			return "poweredOn"
		case .resetting:
			return "resetting"
		case .unauthorized:
			return "unauthorized"
		case .unsupported:
			return "unsupported"
        default:
            return "unknown"
		}
	}
}
