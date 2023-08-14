//
//  ScanDeviceList.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 14/06/2023.
//

import SwiftUI

struct ScanDeviceList: View {
    @StateObject var viewModel = ScannerViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ScanDeviceList_Previews: PreviewProvider {
    static var previews: some View {
        ScanDeviceList()
    }
}
