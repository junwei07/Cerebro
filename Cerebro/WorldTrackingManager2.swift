//
//  WorldTrackingManager2.swift
//  Cerebro
//
//  Created by Interactive 3D Design Group on 8/8/25.
//


import SwiftUI
import Combine
import ARKit
import RealityKit

class WorldTrackingManager2: ObservableObject {
    let session = ARKitSession()
    
    @Published var worldInfo = WorldTrackingProvider()
    var rootEntity = AnchorEntity(world: .zero) //fixed at spawn, root container
    var planeDetectionProvider: PlaneDetectionProvider? //provide plane detection
    
    @Published var detectedPlanes: [PlaneAnchor] = [] //store planes
    
    func startSession() async throws {
        
        
         // Initialize plane detection provider
         let provider = PlaneDetectionProvider(alignments: [.horizontal]) //.vertical])
         self.planeDetectionProvider = provider
         
         try await session.run([provider])
         
         // Listen for plane updates asynchronously
         for await update in provider.anchorUpdates {
             switch update.event { // actions based on event case
                 
             case .added, .updated:
                 // Only accept planes classified as table or seat
                 guard update.anchor.alignment == .horizontal else { continue }
                 guard update.anchor.surfaceClassification == .table || update.anchor.surfaceClassification == .seat else { continue }
                 
                 DispatchQueue.main.async {
                     let isDuplicate = self.detectedPlanes.contains(where: { $0.id == update.anchor.id })
                     
                     if !isDuplicate {
                         self.detectedPlanes.append(update.anchor)
                     } else if let index = self.detectedPlanes.firstIndex(where: { $0.id == update.anchor.id }) {
                         self.detectedPlanes[index] = update.anchor
                     }
                 }
                 
                 await addOrUpdatePlaneEntity(update.anchor)
                 
             case .removed:
                 DispatchQueue.main.async {
                     self.detectedPlanes.removeAll(where: { $0.id == update.anchor.id })
                 }
                 try? removePlaneEntity(update.anchor)
             }
         }
     }
                 
                 /*
              case .added, .updated:
                 // Update detectedPlanes array
                 DispatchQueue.main.async {
                     if !self.detectedPlanes.contains(where: { $0.id == update.anchor.id }) {
                         self.detectedPlanes.append(update.anchor)
                     } else {
                         // update existing plane if needed
                         if let index = self.detectedPlanes.firstIndex(where: { $0.id == update.anchor.id }) {
                             self.detectedPlanes[index] = update.anchor
                         }
                     }
                 }
                 // Update or add visual entities for plane
                 await addOrUpdatePlaneEntity(update.anchor)
             case .removed:
                 DispatchQueue.main.async {
                     self.detectedPlanes.removeAll(where: { $0.id == update.anchor.id })
                 }
                 try? removePlaneEntity(update.anchor)
             }
         }
     }
    */
     
     @MainActor func addOrUpdatePlaneEntity(_ anchor: PlaneAnchor) async {
         // Add or update plane visual entities (similar to PlaneDetectionModel's addBall)
         
         guard anchor.alignment == .horizontal else { return }
         guard anchor.surfaceClassification == .table || anchor.surfaceClassification == .seat else { return }


         let extent = anchor.geometry.extent
         var planeMaterial = PhysicallyBasedMaterial()
         
         //MARK: - to remove material later on, just leave orbs
         //add blue material for plane
         planeMaterial.baseColor = .init(tint: .green.withAlphaComponent(0.1))
         /*
         var planeModelEntity = ModelEntity(
            mesh: .generatePlane(width: extent.width,
                                 height: extent.height),
                                 materials: [planeMaterial])
          
         
//         planeModelEntity.name = "\(anchor.id)"
         
         //rotate it to be flat
         planeModelEntity.transform.rotation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])

         
         //check whether already a visual entity
         if let anchorEntity = rootEntity.findEntity(named: "\(anchor.id)") {
             anchorEntity.children.removeAll()
             anchorEntity.addChild(planeModelEntity)
             
         } else {
             let anchorEntity = AnchorEntity(world: anchor.originFromAnchorTransform)
             anchorEntity.name = "\(anchor.id)"
             anchorEntity.addChild(planeModelEntity)
             rootEntity.addChild(anchorEntity)
         }
          */
     }
     
     func removePlaneEntity(_ anchor: PlaneAnchor) throws {
         if let anchorEntity = rootEntity.findEntity(named: "\(anchor.id)") {
             anchorEntity.removeFromParent()
         }
     }
     
     func stopSession() {
         session.stop()
     }
 }
