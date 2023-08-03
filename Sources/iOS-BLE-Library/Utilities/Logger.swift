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
    static var enabled: Bool {
        return false
    }
    
    let subsystem: String
    let category: String
    
    init(subsystem: String = "com.nordicsemi.ios_ble_library", category: String) {
        self.subsystem = subsystem
        self.category = category
    }
    
    func i(_ msg: String) {
        #if DEBUG
        os_log("%@", type: .info, msg)
        #endif
    }
    
    func d(_ msg: String) {
        #if DEBUG
        os_log("%@", type: .debug, msg)
        #endif
    }
    
    func e(_ msg: String) {
        #if DEBUG
        os_log("%@", type: .error, msg)
        #endif
    }
    
    func f(_ msg: String) {
        #if DEBUG
        os_log("%@", type: .fault, msg)
        #endif
    }
}
