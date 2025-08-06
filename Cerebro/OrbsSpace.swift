//
//  OrbsSpace.swift
//  Cerebro
//
//  Created by Interactive 3D Design Group on 6/8/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct OrbsSpace: View {
    @ObservedObject var appState: AppState
    @State private var orbEntities: [Orb] = []
    @State private var anchor = AnchorEntity(world: [0, 0, 0])

    
//    private var orbs = [
//        Orb(entity: createOrbEntity(num: 1), initPosition: [1,0,-3]),
//        Orb(entity: createOrbEntity(num: 2)<#T##ModelEntity#>, initPosition: [2,0,-3]),
//        Orb(entity: createOrbEntity(num: 3)<#T##ModelEntity#>, initPosition: [3,0,-3]),
//        Orb(entity: createOrbEntity(num: 4)<#T##ModelEntity#>, initPosition: [4,0,-3]),
//    ]
    
    var body: some View {
        
//        VStack {
//            Model3D(named: "Scene", bundle: realityKitContentBundle)
//                .padding(.bottom, 50)
//
//            Text("Hello, world!")
//        }
//        .padding()
        RealityView { content in
//            let anchor = AnchorEntity(world: [0, 0, 0])

//            // original
//            let orbMesh = MeshResource.generateSphere(radius: 0.2)
//            let material = SimpleMaterial(color: .yellow, isMetallic: true)
//            let orbEntity = ModelEntity(mesh: orbMesh, materials: [material])
//            orbEntity.scale = .init(x: 1, y: 1, z: 1)
//            orbEntity.position = .init(x: 0, y: 0, z: -3)
            
            // dummy
            let orbMesh = MeshResource.generateSphere(radius: 0.2)
            
            let orbEntity1 = Orb(
                entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .yellow, isMetallic: true)]),
                initPosition: [-0.75, 0.5, -3]
            )
            let orbEntity2 = Orb(
                entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .blue, isMetallic: true)]),
                initPosition: [-0.25, 0.5, -3]
            )
            
            let orbEntity3 = Orb(
                entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .red, isMetallic: true)]),
                initPosition: [0.25, 0.5, -3]
            )
            let orbEntity4 = Orb(
                entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .green, isMetallic: true)]),
                initPosition: [0.75, 0.5, -3]
            )

//            orbEntity1.position = [-0.75, 0.5, -3]
//            orbEntity2.position = [-0.25, 0.5, -3]
//            orbEntity3.position = [0.25, 0.5, -3]
//            orbEntity4.position = [0.75, 0.5, -3]

            
            // all orbs
            orbEntities = [orbEntity1, orbEntity2, orbEntity3, orbEntity4]

            
//            if let animation =
//                orbEntity.availableAnimations.first {
//                orbEntity.playAnimation(animation.repeat(),
//                                        transitionDuration: 0,
//                                        startsPaused: false 
//                )
//            }
            for orbEntity in orbEntities {
                orbEntity.entity.position = orbEntity.initPosition
                anchor.addChild(orbEntity.entity)
                startFloatingAnimation(orb: orbEntity)
            }
            
            content.add(anchor)

            
        }
        .onChange(of: appState.disperse) { oldValue, newValue in
            if newValue {
                disperseOrbs()
            } else {
                resetOrbs()
            }
        }
        
    }
    
    

    func startFloatingAnimation(orb: Orb) {
        print(orb.initPosition)

            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                while appState.floating {
                    let upTransform = Transform(translation: [orb.entity.position.x, orb.initPosition.y + 0.1, orb.entity.position.z])
                    let downTransform = Transform(translation: [orb.entity.position.x, orb.initPosition.y - 0.1, orb.entity.position.z])

                    orb.entity.move(to: upTransform, relativeTo: orb.entity.parent, duration: 1.0, timingFunction: .easeInOut)
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

                    orb.entity.move(to: downTransform, relativeTo: orb.entity.parent, duration: 1.0, timingFunction: .easeInOut)
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                }
            }
        
    }
    
    func disperseOrbs() {
        // stop the orbs
        appState.floating = false
        
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            // disperse orbs
            for orb in orbEntities {
                // Define random X and Z within limits
                let maxRadius: Float = 10.0
                let minZ: Float = -10.0
                let maxZ: Float = -2.5

                let randomX = Float.random(in: -maxRadius...maxRadius)
                let randomZ = Float.random(in: minZ...maxZ)
                let newPosition = SIMD3<Float>(randomX, orb.initPosition.y, randomZ)

                let transform = Transform(translation: newPosition)

                orb.entity.move(to: transform, relativeTo: orb.entity.parent, duration: 2, timingFunction: .easeInOut)
            }
        }
    }
    
    func resetOrbs() {
        for orb in orbEntities {
            let resetTransform = Transform(translation: orb.initPosition)
            orb.entity.move(to: resetTransform, relativeTo: orb.entity.parent, duration: 1.5, timingFunction: .easeInOut)
        }
    }
}

#Preview("Immersive Style", immersionStyle: .automatic, body: {
    OrbsSpace(appState: .init())
})
