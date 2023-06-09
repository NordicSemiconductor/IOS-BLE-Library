//
//  ServiceList.swift
//  Example
//
//  Created by Nick Kibysh on 23/05/2023.
//

import SwiftUI
import iOS_Bluetooth_Numbers_Database
import CoreBluetooth

struct DeviceServiceList: View {
    struct InternalService: Identifiable {
        let id: String
        let name: String
    }
    
    let services: [InternalService]
    
    init(services: [InternalService]) {
        self.services = services
    }
    
    init(cbuuidServices: [CBUUID]) {
        self.services = cbuuidServices.map{ serviceId in
            InternalService(
                id: serviceId.uuidString,
                name: Service.find(by: CoreBluetooth.CBUUID(string: serviceId.uuidString))?.name ?? "Unknown Service")
        }
    }
    
    var body: some View {
        List {
            ForEach(services) { s in
                serviceView(service: s)
            }
        }
    }
    
    @ViewBuilder
    func serviceView(service: InternalService) -> some View {
        VStack(alignment: .leading) {
            Text(service.name)
                .font(.title)
            Text(service.id)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct DeviceServiceList_Previews: PreviewProvider {
    static var previews: some View {
        DeviceServiceList(services: [
            DeviceServiceList.InternalService(id: UUID().uuidString, name: "Service 1"),
            DeviceServiceList.InternalService(id: UUID().uuidString, name: "Service 2"),
            DeviceServiceList.InternalService(id: UUID().uuidString, name: "Service 3"),
        ])
    }
}