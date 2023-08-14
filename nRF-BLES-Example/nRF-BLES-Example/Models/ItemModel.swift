//
//  ItemModel.swift
//  Example
//
//  Created by Nick Kibysh on 05/04/2023.
//

import Foundation

struct ItemModel<K: Hashable>: Identifiable {
    typealias ID = K
    
    let key: K
    let title: String
    let value: String
    
    var id: K { key }
}

