//
//  PeripheralError.swift
//  iOS-BLE-Library
//
//  Created by Dinesh Harjani on 26/9/25.
//  Copyright © 2025 Nordic Semiconductor ASA. All rights reserved.
//

import Foundation

// MARK: - PeripheralError

public enum PeripheralError: LocalizedError {

	case onlyConnectedPeripheralsHaveNegotiatedMTU

	// MARK: Description

	public var errorDescription: String? {
		switch self {
		case .onlyConnectedPeripheralsHaveNegotiatedMTU:
			return
				"A connected Peripheral is required to obtain a valid negotiated MTU (Maximum Transmission Unit) size."
		}
	}
}
