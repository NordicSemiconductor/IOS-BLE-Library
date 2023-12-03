//
//  File.swift
//
//
//  Created by Nick Kibysh on 20/01/2023.
//

import Foundation
import os

@available(iOS 14.0, macOS 11, *)
private struct Loggers {
    static var loggers: [UUID : Logger] = [:]
}

struct L {
    @inline(__always)
    static let enabled: Bool = true
    
    let subsystem: String
    let category: String
    
    private let shouldLog: Bool
    
    private let id = UUID()
    
    init(
        subsystem: String = "com.nordicsemi.ios_ble_library", category: String,
        enabled: Bool = Self.enabled
    ) {
        self.subsystem = subsystem
        self.category = category
        self.shouldLog = enabled
        
        if #available(iOS 14, macOS 11, *) {
            Loggers.loggers[self.id] = Logger(subsystem: subsystem, category: category)
        }
    }
    
    func i(_ msg: String) {
#if DEBUG
        if !shouldLog { return }
        
        if #available(iOS 14, macOS 11, *) {
            Loggers.loggers[id]?.info("\(msg)")
        } else {
            os_log("%@", type: .info, msg)
        }
        
#endif
    }
    
    func d(_ msg: String) {
#if DEBUG
        if !shouldLog { return }
        if #available(iOS 14, macOS 11, *) {
            Loggers.loggers[id]?.debug("\(msg)")
        } else {
            os_log("%@", type: .debug, msg)
        }
#endif
    }
    
    func e(_ msg: String) {
#if DEBUG
        if !shouldLog { return }
        if #available(iOS 14, macOS 11, *) {
            Loggers.loggers[id]?.error("\(msg)")
        } else {
            os_log("%@", type: .error, msg)
        }
#endif
    }
    
    func f(_ msg: String) {
#if DEBUG
        if !shouldLog { return }
        if #available(iOS 14, macOS 11, *) {
            Loggers.loggers[id]?.fault("\(msg)")
        } else {
            os_log("%@", type: .fault, msg)
        }
#endif
    }
}
