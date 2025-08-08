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
    @State private var anchorTable = AnchorEntity(plane: .horizontal, classification: .table)
    @State private var anchorSeat = AnchorEntity(plane: .horizontal, classification: .seat)
    @State private var userPosition: SIMD3<Float> = .zero
    @State private var selectedOrbs: [Orb] = []
    @State private var finalScoreEntity: Entity? = nil
    @State private var isPlayingMelody: Bool = false
    @State private var tries: Int = 1
    @State private var totalCorrect: Int = 0

    var finalScoreAttachment: some View {
        ScoreView(appState: appState, tries: $tries, totalCorrect: $totalCorrect, orbs: Orbs, selectedOrbs: selectedOrbs)
    }
    
    var body: some View {
        
        RealityView { content, attachments in
            anchor.children.removeAll()
            

            // initialize orbs
            let orbMesh = MeshResource.generateSphere(radius: 0.2)
            
            let orbEntity1 = Orb(
                entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .yellow, isMetallic: true)]),
                initPosition: [-1, 0, -2],
                audioResource: try? await AudioFileResource(named: "V2SoundDo.m4a")
            )
//            orbEntity1.entity.components.set(OpacityComponent(opacity: 1))
            
            let orbEntity2 = Orb(
                entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .blue, isMetallic: true)]),
                initPosition: [-0.5, 0, -2],
                audioResource: try? await AudioFileResource(named: "SoundRe.m4a")
            )
            
            let orbEntity3 = Orb(
                entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .red, isMetallic: true)]),
                initPosition: [0, 0, -2],
                audioResource: try? await AudioFileResource(named: "SoundMi.m4a")
            )
            let orbEntity4 = Orb(
                entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .green, isMetallic: true)]),
                initPosition: [0.5, 0, -2],
                audioResource: try? await AudioFileResource(named: "SoundFa.m4a")
            )
            let orbEntity5 = Orb(
                entity: ModelEntity(mesh: orbMesh, materials: [SimpleMaterial(color: .orange, isMetallic: true)]),
                initPosition: [1, 0, -2],
                audioResource: try? await AudioFileResource(named: "SoundSo.m4a")
            )
            
            // all orbs
            Orbs = [orbEntity1, orbEntity2, orbEntity3, orbEntity4, orbEntity5]


            for orb in Orbs {
                orb.entity.position = orb.initPosition
                orb.entity.generateCollisionShapes(recursive: false)
                orb.entity.components.set(InputTargetComponent(allowedInputTypes: .all))

                anchor.addChild(orb.entity)
                startFloatingAnimation(orb: orb)
            }
            
            content.add(anchor)
            //planes detected by AR session
//            content.add(worldTrackingManager.rootEntity)
            
            try? await worldTrackingManager.startSession()

            // score attachment
            if let finalScoreAttachment = attachments.entity(for: "finalScore") {
                print("rendered final score")
                finalScoreAttachment.components.set(OpacityComponent(opacity: 0))
                finalScoreEntity = finalScoreAttachment
                finalScoreAttachment.position = [0, 1.5, -3]
                anchor.addChild(finalScoreAttachment)
            }
            
        } attachments: {
            Attachment(id: "finalScore") {
                finalScoreAttachment
            }
        }
        .onAppear {
            Task {
                while true {
                    fetchUserPosition()
                    updateScoreViewPosition()
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
                }
            }
        }
        .simultaneousGesture(
            appState.hidingOrbs ?
                SpatialTapGesture()
                    .targetedToAnyEntity()
                    .onEnded({ value in
                        let tappedOrb = value.entity
                        
                        // Find the orb in the Orbs array
                        if let index = Orbs.firstIndex(where: { $0.entity == tappedOrb }) {
                            print("Tapped orb #\(index)")

                            let orb = Orbs[index]
                            
                            // play sound
                            if let audio = orb.audioResource {
                                orb.entity.playAudio(audio)
                            } else {
                                print("⚠️ Audio resource is nil for orb \(index)")
                            }
                                
                            // Avoid duplicates
                            if !selectedOrbs.contains(where: { $0.entity == orb.entity }) {
                                Orbs[index].isSelected = true
                                animateGlow(orb: orb)
                                showOrb(index: index)
                                selectedOrbs.append(orb)
//                                print("selected orbs: \(selectedOrbs)")
                                print("selected orbs: \(selectedOrbs.count)")
                            }
                        }
                    })
            : nil)
        .onChange(of: appState.disperse) { _, newValue in
            if newValue {
                disperseOrbs()
            } else {
                resetOrbs()
            }
        }
        .onChange(of: appState.hidingOrbs) { _, newValue in
            if newValue {
                hideOrbs()
                
                Task {
                    // continuously query for user position
                    while appState.hidingOrbs {
                        //update user position
//                        fetchUserPosition()
                        
//                        if appState.showScore {
//                            if let scoreEntity = finalScoreEntity {
//                                scoreEntity.position = SIMD3<Float>(
//                                    userPosition.x,
//                                    userPosition.y,
//                                    userPosition.z - 1.5
//                                )
//                            }
//                        }

                        
                        for i in Orbs.indices {
                            let orbPos = Orbs[i].entity.position
                            if simd_distance(userPosition, orbPos) < 5 || isPlayingMelody {
                                showOrb(index: i)
//                                print("close enough")
                            } else {
                                if !Orbs[i].isHidden && !Orbs[i].isSelected{
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
        .onChange(of: appState.playingMelody) { _, newValue in
            if newValue {
                playMelody()
                appState.playingMelody = false
            }
        }
        .onChange(of: appState.showHint) { _, newValue in
            appState.hidingOrbs = false
            if newValue {
                playMelody()
                appState.showHint = false
            }
            appState.hidingOrbs = true
        }
        .onChange(of: selectedOrbs.count) { _, newValue in
            if newValue == 5 {
                guard let entity = finalScoreEntity else { return }
                entity.components.set(OpacityComponent(opacity: 1))
                print("show score")
                appState.showHint = true
            } else {
                guard let entity = finalScoreEntity else { return }
                entity.components.set(OpacityComponent(opacity: 0))
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
//        print(userPosition)
        
    }

    func startFloatingAnimation(orb: Orb) {
//        print(orb.initPosition)

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
    
    func animateGlow(orb: Orb) {
        // Store the original material
        let originalMaterial = orb.entity.model?.materials.first

        // Create a bright glowing material
        let glowingMaterial = UnlitMaterial(color: .white)

        // Apply the glowing material
        orb.entity.model?.materials = [glowingMaterial]

        Task {
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.5 seconds
            if let original = originalMaterial {
                orb.entity.model?.materials = [original]
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
                let maxRadius: Float = 5.0
                let minZ: Float = -5.0
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
        appState.disperse = false
        
        
        for i in Orbs.indices {
            Orbs[i].isSelected = false
            Orbs[i].isHidden = false
            showOrb(index: i)
        }
        
        for orb in Orbs {
            let resetTransform = Transform(translation: orb.initPosition)
            orb.entity.move(to: resetTransform, relativeTo: orb.entity.parent, duration: 1.5, timingFunction: .easeInOut)
//            startFloatingAnimation(orb: orb)
        }
        
        selectedOrbs = []
        
        
    }
    
    func hideOrbs() {
        for i in Orbs.indices {
            hideOrb(index: i)
        }
    }
    
    func hideOrb(index: Int) {
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
        if isPlayingMelody || appState.showHint {
            animateOpacity(of: Orbs[index].entity, to: 1, duration: 0.2)
        } else if Orbs[index].isSelected {
            animateOpacity(of: Orbs[index].entity, to: 1, duration: 0.5)
        } else {
            animateOpacity(of: Orbs[index].entity, to: 1, duration: 1.5)
        }
        
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
    
    func animateOpacityAsync(of entity: ModelEntity, to targetOpacity: Float, duration: TimeInterval) async {

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
        try? await Task.sleep(nanoseconds: 100_000_000)
    }
    
    func playMelody() {
        isPlayingMelody = true
        Task {
            for i in Orbs.indices {
        
                let orb = Orbs[i]
                // 1. Set orb to visible before animating
//                            orb.entity.components.set(OpacityComponent(opacity: 0))
                            Orbs[i].isHidden = false

                            // 2. Animate opacity to 1.0 (fade in)
                await animateOpacityAsync(of: orb.entity, to: 1.0, duration: 0.5)

                            // 3. Wait briefly after animation, then play sound
                            if let audio = orb.audioResource {
                                orb.entity.playAudio(audio)
                            } else {
                                print("⚠️ Audio resource is nil for orb \(i)")
                            }
                try? await Task.sleep(nanoseconds: 100_000_000)
                
            }
            isPlayingMelody = false
        }
        
    }
    
    func updateScoreViewPosition() {
        guard let scoreEntity = finalScoreEntity else { return }

        scoreEntity.position = SIMD3<Float>(
            userPosition.x,
            userPosition.y,
            userPosition.z - 0.5
        )
    }
    
}

#Preview("Immersive Style", immersionStyle: .automatic, body: {
    OrbsSpace(appState: .init(), worldTrackingManager: .init())
})
