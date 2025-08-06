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
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Welcome to Cerebro!")
            
            if (!isImmersive) {
                Button("Show Orbs") {
                    Task {
                        await self.openImmersiveSpace(id: "Forest")
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
            
            isImmersive ? Text("Immersive space is open") : Text("Immersive space is closed")
            
            if (appState.disperse) {
                Text("dispersing...")
                Button("Reset") {
                    appState.disperse = false
                }
            }
            
        }
        .frame(width: 600, height: 400)
        .padding()
        .glassBackgroundEffect()
//        .windowResizability(.contentSize)
//        RealityView { content in
//            let orbMesh = MeshResource.generateSphere(radius: 0.2)
//            let material = SimpleMaterial(color: .yellow, isMetallic: true)
//            let orbEntity = ModelEntity(mesh: orbMesh, materials: [material])
//            orbEntity.scale = .init(x: 1, y: 1, z: 1)
//            orbEntity.position = .init(x: 0, y: 0, z: -3)
//            content.add(orbEntity)
            
            // use for loading of pers
//            guard let orbEntity else { return }
            
        }
    
    
}

#Preview {
    ContentView(appState: .init())
}
