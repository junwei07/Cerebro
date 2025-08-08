//
//  ContentView.swift
//  Cerebro
//
//  Created by Interactive 3D Design Group on 6/8/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @ObservedObject var appState: AppState
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var isImmersive = false
    @State private var isFloating = false
    
    var body: some View {
        VStack {
//            Model3D(named: "Scene", bundle: realityKitContentBundle)
//                .padding(.bottom, 50)

            Text("Welcome to SEEK.")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if (!isImmersive) {
                Button("Show Orbs") {
                    Task {
                        await self.openImmersiveSpace(id: "OrbSpace")
                    }
                    isImmersive = true
                    appState.floating = true
                }
            }
            
            if (isImmersive && !appState.disperse) {
                Button("Hide Orbs") {
                    Task {
                        await self.dismissImmersiveSpace()
                    }
                    isImmersive = false
                    
                }
                Button("Disperse") {
                    appState.disperse = true
                }
            }
            
//            if !appState.withSound {
//                Button("On Sound") {
//                    appState.withSound = true
//                }
//            } else {
//                Button("Off Sound") {
//                    appState.withSound = false
//                }
//            }
            
//            isImmersive ? Text("Immersive space is open") : Text("Immersive space is closed")
            
            if (appState.disperse) {
                Text("dispersing...")
                Button("Reset") {
                    appState.disperse = false
                }
                
                if (appState.hidingOrbs) {
                    Button("Show Orbs") {
                        appState.hidingOrbs = false
                    }

                } else {
                    
                    Button("Hide Orbs") {
                        appState.hidingOrbs = true
                    }
                }
                Button("Play Melody") {
                    appState.playingMelody = true
                }
            }
            
            if appState.hidingOrbs {
                Button("Hint") {
                    appState.showHint = true
                }
            }
        }
        .frame(width: 600, height: 400)
        .padding()
        .glassBackgroundEffect()
        }
    
    
}

#Preview {
    ContentView(appState: .init())
}
