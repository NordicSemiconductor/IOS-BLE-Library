//
//  ViewModifier+OS.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 07/06/2023.
//

import SwiftUI

struct UniversalNavigationBarTitleDisplayMode: ViewModifier {
    enum TitleDisplayMode {
        case automatic
        case inline
        case large
    }
    
    let mode: TitleDisplayMode
    
    func body(content: Content) -> some View {
        #if os(iOS)
        content.navigationBarTitleDisplayMode(mode.toNavigationBarItem())
        #else
        content
        #endif
    }
}

extension View {
    func universalNavigationBarTitleDisplayMode(_ mode: UniversalNavigationBarTitleDisplayMode.TitleDisplayMode) -> some View {
        modifier(UniversalNavigationBarTitleDisplayMode(mode: mode))
    }
}

#if os(iOS)
private extension UniversalNavigationBarTitleDisplayMode.TitleDisplayMode {
    func toNavigationBarItem() -> NavigationBarItem.TitleDisplayMode {
        switch self {
        case .automatic: return .automatic
        case .inline: return .inline
        case .large: return .large
        }
    }
}
#endif
