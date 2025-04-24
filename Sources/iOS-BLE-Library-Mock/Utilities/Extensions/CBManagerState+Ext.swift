//
//  File.swift
//
//
//  Created by Nick Kibysh on 19/04/2023.
//

import CoreBluetoothMock
import Foundation

extension CBManagerState {
	
    var ready: Bool? {
		switch self {
		case .poweredOn:
			return true
		case .unknown, .resetting:
			return nil
		case .poweredOff, .unauthorized, .unsupported:
			return false
        default:
            return false
		}
	}
}
