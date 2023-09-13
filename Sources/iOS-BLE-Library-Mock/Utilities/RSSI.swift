//
//  RSSI.swift
//  iOS-BLE-Library
//
//  Created by Dinesh Harjani on 23/8/22.
//

import Foundation

// MARK: - RSSI

private struct Const {
	public static let outOfRange = 127
	public static let practicalWorst = -100
	public static let bad = -90
	public static let ok = -80
	public static let good = 50
}

public struct RSSI: ExpressibleByIntegerLiteral, Equatable, Hashable {

	public enum Signal {
		case outOfRange
		case practicalWorst
		case bad
		case ok
		case good

		init(rssi: Int) {
			switch rssi {
			case let x where x == Const.outOfRange: self = .outOfRange
			case let x where x < Const.bad: self = .practicalWorst
			case let x where x < Const.ok: self = .bad
			case let x where x < Const.good: self = .ok
			default: self = .good
			}
		}
	}

	public typealias IntegerLiteralType = Int

	// MARK: Properties

	public let value: Int
	public let signal: Signal

	// MARK: Init

	public init(integerLiteral value: Int) {
		self.value = value
		self.signal = Signal(rssi: value)
	}
}

// MARK: - Constants

extension RSSI {

	public static let outOfRange = RSSI(integerLiteral: Const.outOfRange)
	public static let practicalWorst = RSSI(integerLiteral: Const.practicalWorst)
	public static let bad = RSSI(integerLiteral: Const.bad)
	public static let ok = RSSI(integerLiteral: Const.ok)
	public static let good = RSSI(integerLiteral: Const.good)
}
