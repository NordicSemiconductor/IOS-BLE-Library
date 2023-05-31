//
//  String+Ext.swift
//  Example
//
//  Created by Nick Kibysh on 07/05/2023.
//

import Foundation

extension StringProtocol {
    func nilOnEmpty() -> Self? {
        self.isEmpty ? nil : self 
    }
}
