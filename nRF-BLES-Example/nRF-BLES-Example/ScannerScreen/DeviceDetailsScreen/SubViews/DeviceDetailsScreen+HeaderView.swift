//
//  DeviceDetailsScreen+HeaderView.swift
//  Example
//
//  Created by Nick Kibysh on 02/05/2023.
//

import SwiftUI
import iOS_BLE_Library

extension DeviceDetailsScreen {
    struct HeaderView: View {
        let name: String
        let rssi: RSSI
        let connectable: Bool
        let state: CBPeripheralState
        
        var body: some View {
            HStack() {
                RSSIView(rssi: rssi)
                    .frame(width: 60)
                Text(name)
                    .font(.headline)
                Spacer()
                if connectable {
                    switch state {
                    case .disconnected:
                        Image(systemName: "link.circle")
                            .foregroundColor(.gray)
                    case .connecting, .disconnecting:
                        Image(systemName: "link.circle")
                            .foregroundColor(.yellow)
                    case .connected:
                        Image(systemName: "link.circle.fill")
                            .foregroundColor(.green)
                    @unknown default:
                        fatalError()
                    }
                }
            }
        }
    }
}

struct DeviceDetailsScreen_HeaderView_Previews: PreviewProvider {
    typealias HeaderView = DeviceDetailsScreen.HeaderView
    
    static var previews: some View {
        Form {
            Section("Devices") {
                HeaderView(name: "Device 1", rssi: .good, connectable: true, state: .disconnected)
                HeaderView(name: "Device 2", rssi: .ok, connectable: false, state: .disconnected)
                HeaderView(name: "Device 3", rssi: .bad, connectable: true, state: .connected)
                HeaderView(name: "Device 4", rssi: .practicalWorst, connectable: false, state: .disconnected)
                HeaderView(name: "Device 5", rssi: .outOfRange, connectable: true, state: .disconnecting)
            }
        }
    }
}
