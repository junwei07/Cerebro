//
//  WorldTrackingManager.swift
//  Cerebro
//
//  Created by Interactive 3D Design Group on 7/8/25.
//

import SwiftUI
import Combine
import ARKit

class WorldTrackingManager: ObservableObject {
    let session = ARKitSession()
    @Published var worldInfo = WorldTrackingProvider()


    func startSession() async throws {
        Task {
            try await session.run([worldInfo])
                        
            for await update in worldInfo.anchorUpdates {
                switch update.event {
                case .added, .updated:
                    // Update the app's understanding of this world anchor.
                    print("Anchor position updated.")
                case .removed:
                    // Remove content related to this anchor.
                    print("Anchor position now unknown.")
                }
            }
        }
    }
}
