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
    
    // track plane IDs assigned to orbs
    // MARK: - to store 4 ORBS positions (fixed after assigned)
    @State private var orbAssignments: [UUID?] = [nil, nil, nil, nil]
    
    // store actual plane positionals in anchor coordinate systems
//    @State private var orbPlanePositions: [SIMD3<Float>?] = [nil, nil, nil, nil]
    @State private var content: RealityViewContent?

    
    @State private var anchor = AnchorEntity(world: [0, 0, 0])
    @State private var userPosition: SIMD3<Float> = .zero
    @State private var selectedOrb: Orb?
    
    //    @State var planeDetection = PlaneDetectionModel()
    
    var body: some View {
        
        RealityView { content in
            self.content = content
            // Initialize orbs once (only if empty)
            if Orbs.isEmpty {
                let orbMesh = MeshResource.generateSphere(radius: 0.2)

                let orbEntity1 = Orb(
                    entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .yellow, isMetallic: true)]),
                    initPosition: [-0.75, 0.5, -3],
                    clusterPosition: [-0.75, 0.5, -3]
                )
                orbEntity1.entity.components.set(OpacityComponent(opacity: 1))

                let orbEntity2 = Orb(
                    entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .blue, isMetallic: true)]),
                    initPosition: [-0.25, 0.5, -3],
                    clusterPosition: [-0.25, 0.5, -3]
                    
                )

                let orbEntity3 = Orb(
                    entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .red, isMetallic: true)]),
                    initPosition: [0.25, 0.5, -3],
                    clusterPosition: [0.25, 0.5, -3]
                )
                let orbEntity4 = Orb(
                    entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .green, isMetallic: true)]),
                    initPosition: [0.75, 0.5, -3],
                    clusterPosition: [0.75, 0.5, -3]
                )

                Orbs = [orbEntity1, orbEntity2, orbEntity3, orbEntity4]

                for orb in Orbs {
                    orb.entity.position = orb.initPosition
                    anchor.addChild(orb.entity)
                    startFloatingAnimation(orb: orb)
                }
                content.add(anchor)
            }
            
            //planes detected by AR session
            content.add(worldTrackingManager.rootEntity)

            // Start session
            Task {
                try? await worldTrackingManager.startSession()
            }
        }
        // when list of detect planes change, assign orbs to planes
        .onReceive(worldTrackingManager.$detectedPlanes) { _ in
            assignOrbsToPlanes()
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
                    while appState.hidingOrbs {
                        fetchUserPosition()

                        for i in Orbs.indices {
                            let orbPos = Orbs[i].entity.position
                            if simd_distance(userPosition, orbPos) < 5 {
                                showOrb(index: i)
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
    
    
    func assignOrbsToPlanes() {
        print("Assigning Orbs to planes...")
        // Only assign if we have at least 4 planes and orbs are unassigned
        guard worldTrackingManager.detectedPlanes.count >= 4 else {
            print("Not enough planes observed, only found \(worldTrackingManager.detectedPlanes.count). Please move around more.")
            return
        }
        
        for plane in worldTrackingManager.detectedPlanes {
            // Skip if this plane's ID is already assigned to any orb
            print(plane.id)
            if orbAssignments.contains(plane.id) {
                continue
            }
            if let index = orbAssignments.firstIndex(where: { $0 == nil }) {
                orbAssignments[index] = plane.id
                
                //print("test anchor: \(anchor)")
                if let anchorEntity = worldTrackingManager.detectedPlanes.first(where: { $0.id == plane.id } ) {
                    let anchor = anchorEntity.originFromAnchorTransform.columns.3

                    let targetPos = SIMD3<Float>(anchor.x, anchor.y + 0.2, anchor.z)
                    
//                    var planeMaterial = PhysicallyBasedMaterial()
//                    
//                    var sphere = ModelEntity(
//                        mesh: .generateSphere(radius: 0.3))
//                    sphere.setPosition(targetPos, relativeTo: nil)
//                    self.content?.add(sphere)
                    
                    print("target Pos: \(targetPos)")
                    // MARK: - error occurs when balls still take this initial targetPos
                    
                    //Orbs[index].entity.move(to: Transform(translation: targetPos), relativeTo: worldTrackingManager.rootEntity, duration: 1.5, timingFunction: .easeInOut)
                    
                    Orbs[index].initPosition = targetPos
                }
            } else {
                // All 4 orbs assigned
                break
            }
            
        }
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
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            while appState.floating {
                let upTransform = Transform(translation: [orb.entity.position.x, orb.initPosition.y + 0.1, orb.entity.position.z])
                let downTransform = Transform(translation: [orb.entity.position.x, orb.initPosition.y - 0.1, orb.entity.position.z])

                orb.entity.move(to: upTransform, relativeTo: orb.entity.parent, duration: 1.0, timingFunction: .easeInOut)
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                orb.entity.move(to: downTransform, relativeTo: orb.entity.parent, duration: 1.0, timingFunction: .easeInOut)
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
    
    func disperseOrbs() {
        // stop the orbs floating animation
        appState.floating = false
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            // disperse orbs
            
            for i in Orbs.indices {
                // Check if orb has an assigned plane
                if let planeID = orbAssignments[i], //orbAssignments[i] gives the planeID i.e plane's UUID
                    // Move orb to assigned plane's position (initPosition was updated to plane pos on assignment)
                    let anchorEntity = worldTrackingManager.rootEntity.findEntity(named: "\(planeID)") {
                        
                        let planePos = anchorEntity.position(relativeTo: worldTrackingManager.rootEntity)
                        let targetPosition = SIMD3<Float>(planePos.x, planePos.y + 0.2, planePos.z)
                        Orbs[i].initPosition = targetPosition
                        print("disperse: moving orb\(i) to \(targetPosition)")
                    
                        let transform = Transform(translation: targetPosition)

                        Orbs[i].entity
                            .move(to: transform,
                                  relativeTo: worldTrackingManager.rootEntity,
                                  duration: 2,
                                  timingFunction: .easeInOut)

                } else {
                    print("No plane assigned for orb \(i)")
                    // If no plane assigned, fallback to initial cluster position
                    let clusterPosition = Orbs[i].initPosition
                    
                    let transform = Transform(translation: clusterPosition)
                    
                    Orbs[i].entity.move(to: transform, relativeTo: worldTrackingManager.rootEntity, duration: 2, timingFunction: .easeInOut)
                }
            }
        }
    }
    
    func resetOrbs() {
        appState.hidingOrbs = false
        
        for i in Orbs.indices {
            showOrb(index: i)
        }
        
        for orb in Orbs {
            let resetTransform = Transform(translation: orb.clusterPosition)
            orb.entity.move(to: resetTransform,
                            relativeTo: orb.entity.parent,
                            duration: 1.5,
                            timingFunction: .easeInOut)
        }
        
        //start floating again
        appState.floating = true
        for orb in Orbs {
            startFloatingAnimation(orb: orb)
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

