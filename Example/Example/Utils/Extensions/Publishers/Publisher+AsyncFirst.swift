//
//  Publisher+AsyncFirst.swift
//  Example
//
//  Created by Nick Kibysh on 04/05/2023.
//

import Foundation
import Combine

//extension Publishers.Autoconnect where Upstream == Publishers.Peripheral {
//
//    var value {
//        async throws get {
//            try await ContinuationSubscriber<Self>.withCheckedContinuation(self)
//        }
//    }
    
    /*
    func firstValue() async -> Output where Failure == Never {
        await withCheckedContinuation { continuation in
            _ = self.first()
                .sink(receiveValue: { v in
                    continuation.resume(with: .success(v))
                })
        }
    }
    
    func firstValue() async throws -> Output {
        try await withCheckedThrowingContinuation({ continuation in
            _ = self.first()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let e):
                        continuation.resume(throwing: e)
                    case .finished:
                        break
                    }
                }, receiveValue: { v in
                    continuation.resume(with: .success(v))
                })
        })
    }
     */
//}
