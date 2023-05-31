//
//  RSSI+Color.swift
//  Example
//
//  Created by Nick Kibysh on 03/05/2023.
//

import iOS_BLE_Library
import SwiftUI

extension RSSI.Signal {
    var color: Color {
        switch self {
        case .good: return .green
        case .ok: return .yellow
        case .bad: return .orange
        case .practicalWorst: return .red
        case .outOfRange: return .gray
        }
    }
}
