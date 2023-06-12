//
//  Device.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 11/06/2023.
//

import Foundation
#if os(iOS)
import UIKit
#endif 

enum PhysicalDevice {
    case mac, phone, pad
    
    static var current: PhysicalDevice {
#if os(iOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return .phone
        default:
            return .pad
        }
#else
        return .mac
#endif
    }
}
