//
//  File.swift
//
//
//  Created by Nick Kibysh on 20/01/2023.
//

import Foundation
import os

struct L {
	@inline(__always)
	static let enabled: Bool = false

	let subsystem: String
	let category: String

	private let shouldLog: Bool

	init(
		subsystem: String = "com.nordicsemi.ios_ble_library", category: String,
		enabled: Bool = Self.enabled
	) {
		self.subsystem = subsystem
		self.category = category
		self.shouldLog = enabled
	}

	func i(_ msg: String) {
		#if DEBUG
			if !shouldLog { return }
			os_log("%@", type: .info, msg)
		#endif
	}

	func d(_ msg: String) {
		#if DEBUG
			if !shouldLog { return }
			os_log("%@", type: .debug, msg)
		#endif
	}

	func e(_ msg: String) {
		#if DEBUG
			if !shouldLog { return }
			os_log("%@", type: .error, msg)
		#endif
	}

	func f(_ msg: String) {
		#if DEBUG
			if !shouldLog { return }
			os_log("%@", type: .fault, msg)
		#endif
	}
}
