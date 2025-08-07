//
//  AppState.swift
//  Cerebro
//
//  Created by Interactive 3D Design Group on 6/8/25.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
//    static let shared = AppState()
    @Published var isImmersive: Bool = false
    @Published var disperse: Bool = false
    @Published var floating: Bool = false
    @Published var hidingOrbs: Bool = false
}
