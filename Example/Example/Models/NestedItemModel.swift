//
//  NestedItemModel.swift
//  Example
//
//  Created by Nick Kibysh on 05/04/2023.
//

import Foundation

protocol NestedModel: Identifiable {
    var level: UInt { get }
}

protocol NestedStringRepresentable: NestedModel, CustomStringConvertible { }
