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
    @StateObject private var worldTrackingManager = WorldTrackingManager()
    @StateObject private var worldTrackingManager2 = WorldTrackingManager2()
    @State var immersionStyle : ImmersionStyle = .mixed
    @State var backgroundisdark = true
    
    var body: some Scene {
        WindowGroup(id: "MainWindow") {
            MainAppView(backgroundisdark: $backgroundisdark)
        }
        
        ImmersiveSpace(id: "DarkBackground") {
            MyImmersiveView(backgroundisdark: $backgroundisdark)
        }
        
        WindowGroup(id: "ContentView") {
            ContentView(appState: appState)
        }
        .windowResizability(.automatic)
        
        ImmersiveSpace(id: "OrbSpace") {
            OrbsSpace(appState: appState, worldTrackingManager: worldTrackingManager,
                      worldTrackingManager2: worldTrackingManager2)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .full, .progressive)
    }
}
