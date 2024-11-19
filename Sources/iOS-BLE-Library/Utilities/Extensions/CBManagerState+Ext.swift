//
//  File.swift
//
//
//  Created by Nick Kibysh on 19/04/2023.
//

//CG_REPLACE
import CoreBluetooth
//CG_WITH
/*
import CoreBluetoothMock
*/
//CG_END
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
