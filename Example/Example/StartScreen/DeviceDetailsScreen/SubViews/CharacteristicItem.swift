//
//  CharacteristicItem.swift
//  Example
//
//  Created by Nick Kibysh on 07/05/2023.
//

import SwiftUI

extension DeviceDetailsScreen {
    struct CharacteristicItem: View {
        let characterstic: ViewModel.Attributes
        let action: () -> Void
        
        var body: some View {
            NestedItemView(level: 2) {
                Button (
                    action: action,
                    label: {
                        VStack(alignment: .leading) {
                            Text(characterstic.name)
                            characterstic.captions.flatMap {
                                Text($0)
                                    .font(.caption)
                            }
                        }
                    }
                )
            }
        }
    }
}

struct CharacteristicItem_Previews: PreviewProvider {
    typealias CharacteristicItem = DeviceDetailsScreen.CharacteristicItem
    typealias Attribute = DeviceDetailsScreen.ViewModel.Attributes
    
    static var previews: some View {
        Form {
            CharacteristicItem(
                characterstic: Attribute(
                    id: "",
                    level: 2,
                    name: "Characteristic",
                    captions: "Read, Write",
                    inner: []
                )) {
                    
                }
        }
    }
}
