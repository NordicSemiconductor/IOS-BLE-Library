//
//  ServiceListSelector.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 02/06/2023.
//

import SwiftUI
import iOS_Bluetooth_Numbers_Database
import Combine

extension Service: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.uuid)
    }
}

struct ServiceListSelector: View {
    let services: [Service]
    @State var searchText: String = ""
    
    @State private var showCustomService: Bool = false
    
    @StateObject private var viewModel = ViewModel()
    
    let alreadySelectedServices: [Service]
    let selectionHandler: (Service) -> ()
    
    init(alreadySelectedServices: [Service], selectionHandler: @escaping (Service) -> ()) {
        self.alreadySelectedServices = alreadySelectedServices
        self.selectionHandler = selectionHandler
        self.services = Service.all.filter { !alreadySelectedServices.contains($0) }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if searchResults.isEmpty {
                    addCustomService()
                } else {
                    List(searchResults) { sr in
                        Button {
                            selectionHandler(sr)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(sr.name)
                                Text(sr.uuidString)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Services")
        }
        .searchable(text: $searchText)
    }
    
    @ViewBuilder
    func addCustomService() -> some View {
        VStack {
            Image(systemName: "binoculars")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .foregroundColor(.secondary)
            
            Text("No Results")
                .foregroundColor(.secondary)
                .font(.largeTitle)
            Button("Add Custom Service") {
                showCustomService = true
            }
            .navigationDestination(isPresented: $showCustomService) {
                CustomServiceView(selectionHandler: self.selectionHandler)
            }
        }
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

extension ServiceListSelector {
    @MainActor
    fileprivate class ViewModel: ObservableObject {
        private var cancelable: AnyCancellable?
        
        @Published var selectedService: Service?
        var selectionHandler: ((Service) -> ())?
        
        init() {
            cancelable = selectedService.publisher.sink(receiveValue: { service in
                self.selectionHandler?(service)
            })
        }
        
    }
}

struct ServiceListView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceListSelector(alreadySelectedServices: []) { _ in }
    }
}
