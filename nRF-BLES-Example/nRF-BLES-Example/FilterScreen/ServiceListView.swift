//
//  ServiceListView.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 02/06/2023.
//

import SwiftUI
import iOS_Bluetooth_Numbers_Database

extension Service: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.uuid)
    }
}

struct ServiceListView: View {
    let services = Service.all//.sorted(by: { $0.name < $1.name })
    @State var searchText: String = ""
    @State var selectedService: Service?
    
    var body: some View {
        NavigationStack {
            VStack {
                if searchResults.isEmpty {
                    VStack {
                        Image(systemName: "binoculars")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                        .foregroundColor(.secondary)
                        
                        Text("No Results")
                            .foregroundColor(.secondary)
                            .font(.largeTitle)
                    }
                } else {
                    EmptyView()
//                    List(services, id: \.uuid, selection: $selectedService) { service in
//
//                    }
                }
            }
            .navigationTitle("Services")
        }
        .searchable(text: $searchText)
    }
    
    var searchResults: [Service] {
        if searchText.isEmpty {
            return services
        } else {
            return services.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.uuidString.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

struct ServiceListView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceListView()
    }
}
