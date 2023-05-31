//
//  Array+Ext.swift
//  Example
//
//  Created by Nick Kibysh on 29/03/2023.
//

import Foundation

extension Array {
    mutating func appendOrReplace(_ element: Element, where exists: (Element) -> Bool ) {
        if let index = firstIndex(where: exists) {
            self[index] = element
        } else {
            self.append(element)
        }
    }
    
    func appendedOrReplaced(_ element: Element, where exists: (Element) -> Bool ) -> [Element] {
        var new = self
        if let index = new.firstIndex(where: exists) {
            new[index] = element
        } else {
            new.append(element)
        }
        return new
    }
}

extension Array where Element: Equatable {
    mutating func appendOrReplace(_ element: Element) {
        if let index = firstIndex(of: element) {
            self[index] = element
        } else {
            self.append(element)
        }
    }
    
    func appendedOrReplaced(_ element: Element) -> [Element] {
        var new = self
        if let index = firstIndex(of: element) {
            new[index] = element
        } else {
            new.append(element)
        }
        return new
    }
}
