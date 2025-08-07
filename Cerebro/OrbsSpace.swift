//
//  OrbsSpace.swift
//  Cerebro
//
//  Created by Interactive 3D Design Group on 6/8/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct OrbsSpace: View {
    @ObservedObject var appState: AppState
    @ObservedObject var worldTrackingManager: WorldTrackingManager
//    @Environment(\.openWindow) private var openWindow
    @State private var Orbs: [Orb] = []
    @State private var anchor = AnchorEntity(world: [0, 0, 0])
    @State private var userPosition: SIMD3<Float> = .zero
    @State private var selectedOrb: Orb?
    
    var body: some View {
        
//        VStack {
//            Model3D(named: "Scene", bundle: realityKitContentBundle)
//                .padding(.bottom, 50)
//
//            Text("Hello, world!")
//        }
//        .padding()
        
        
        RealityView { content in
            
            // initialize orbs
            let orbMesh = MeshResource.generateSphere(radius: 0.2)
            
            let orbEntity1 = Orb(
                entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .yellow, isMetallic: true)]),
                initPosition: [-0.75, 0.5, -3]
            )
            orbEntity1.entity.components.set(OpacityComponent(opacity: 1))
            
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
            
            // all orbs
            Orbs = [orbEntity1, orbEntity2, orbEntity3, orbEntity4]


            for orb in Orbs {
                orb.entity.position = orb.initPosition
                anchor.addChild(orb.entity)
                startFloatingAnimation(orb: orb)
            }
            
            content.add(anchor)
            
            try? await worldTrackingManager.startSession()

            
        }
        .onChange(of: appState.disperse) { oldValue, newValue in
            if newValue {
                disperseOrbs()
            } else {
                resetOrbs()
            }
        }
        .onChange(of: appState.hidingOrbs) { oldValue, newValue in
            if newValue {
                hideOrbs()
                
                Task {
                    // continuously query for user position
                    while appState.hidingOrbs {
                        //update user position
                        fetchUserPosition()
                        
                        // compare to each orb's position
//                        for orb in Orbs {
//                            let orbPos = orb.entity.position
//                            if simd_distance(userPosition, orbPos) < 5 {
//                                showOrb(orb: orb)
//                                print("close enough")
//                            } else {
////                                if !orb.isHidden {
////                                    hideOrb(orb: orb)
////                                }
//                            }
//                        }
                        
                        for i in Orbs.indices {
                            let orbPos = Orbs[i].entity.position
                            if simd_distance(userPosition, orbPos) < 5 {
                                showOrb(index: i)
                                print("close enough")
                            } else {
                                if !Orbs[i].isHidden {
                                    hideOrb(index: i)
                                }
                            }
                        }
                        
                        try? await Task.sleep(nanoseconds: 100_000_000)
                    }
                }
            } else {
                
                showOrbs()
            }
            
        }
        .gesture(SpatialTapGesture().targetedToEntity(anchor).onEnded({ value in
            let orbEntity = value.entity
            
            print("tapped \(orbEntity)")
        }))
        
    }
    
    func fetchUserPosition() {
        guard let matrix = worldTrackingManager.worldInfo.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())?.originFromAnchorTransform else {
                print("User position not available")
                userPosition = .zero
                return
            }
        
        
        let translation = matrix.columns.3
        userPosition = SIMD3<Float>(translation.x, translation.y, translation.z)
        print(userPosition)
        
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
            for orb in Orbs {
                // Define random X and Z within limits
                let maxRadius: Float = 10.0
                let minZ: Float = -10.0
                let maxZ: Float = -3

                let randomX = Float.random(in: -maxRadius...maxRadius)
                let randomZ = Float.random(in: minZ...maxZ)
                let newPosition = SIMD3<Float>(randomX, orb.initPosition.y, randomZ)

                let transform = Transform(translation: newPosition)

                orb.entity.move(to: transform, relativeTo: orb.entity.parent, duration: 2, timingFunction: .easeInOut)
            }
        }
    }
    
    func resetOrbs() {
        appState.hidingOrbs = false
        
        for i in Orbs.indices {
            showOrb(index: i)
        }
        
        for orb in Orbs {
            let resetTransform = Transform(translation: orb.initPosition)
            orb.entity.move(to: resetTransform, relativeTo: orb.entity.parent, duration: 1.5, timingFunction: .easeInOut)
//            startFloatingAnimation(orb: orb)
        }
        
        
    }
    
    func hideOrbs() {
//        for orb in Orbs {
//            animateOpacity(of: orb.entity, to: 0, duration: 2)
//        }
        for i in Orbs.indices {
                hideOrb(index: i)
            }
    }
    
    func hideOrb(index: Int) {
//        animateOpacity(of: orb.entity, to: 0, duration: 2)
        animateOpacity(of: Orbs[index].entity, to: 0, duration: 2)
            Orbs[index].isHidden = true
    }
    
    func showOrbs() {
//        for orb in Orbs {
//            animateOpacity(of: orb.entity, to: 1, duration: 2)
//        }
        for i in Orbs.indices {
                showOrb(index: i)
            }
    }
    
    func showOrb(index: Int) {
//        animateOpacity(of: orb.entity, to: 1, duration: 2)
        animateOpacity(of: Orbs[index].entity, to: 1, duration: 2)
            Orbs[index].isHidden = false
    }
    
    func animateOpacity(of entity: ModelEntity, to targetOpacity: Float, duration: TimeInterval) {

        let animation = FromToByAnimation<Float>(
            from: entity.components[OpacityComponent.self]?.opacity,
            to: targetOpacity,
            duration: duration,
            timing: .easeInOut,
            bindTarget: .opacity
        )
        
        // Create an AnimationView using the defined animation with a delay
        let animationViewDefinition = AnimationView(source: animation, speed: 0.5)

        // Generate an AnimationResource from the AnimationViewDefinition
        let animationResource = try! AnimationResource.generate(with: animationViewDefinition)

        entity.playAnimation(animationResource)
    }
}

#Preview("Immersive Style", immersionStyle: .automatic, body: {
    OrbsSpace(appState: .init(), worldTrackingManager: .init())
})
