//
//  CerebroApp.swift
//  Cerebro
//
//  Created by Interactive 3D Design Group on 6/8/25.
//

import SwiftUI

@main
struct CerebroApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
        }
        .windowResizability(.automatic)
        
        ImmersiveSpace(id: "Forest") {
            OrbsSpace(appState: appState)
        }
//        .immersionStyle(selection:.constant(.full), in: .full)
    }
}
