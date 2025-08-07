//
//  OrbModel.swift
//  Cerebro
//
//  Created by Interactive 3D Design Group on 6/8/25.
//

import Foundation
import SwiftUI
import RealityKit
import RealityKitContent

struct Orb: Identifiable {
    var id = UUID()
    var entity: ModelEntity
    var initPosition: SIMD3<Float> //to be updated
    var isHidden: Bool = false
    var clusterPosition: SIMD3<Float> // original starting position fixed
    
}

