//
//  StartSplitView.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 14/06/2023.
//

import SwiftUI

struct StartSplitView: View {
    var body: some View {
        NavigationSplitView(
            columnVisibility: .constant(.doubleColumn)) {
                Text("Scanner")
            } detail: {
                Text("Details")
            }

    }
}

struct StartSplitView_Previews: PreviewProvider {
    static var previews: some View {
        StartSplitView()
    }
}
