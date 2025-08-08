import SwiftUI
import RealityKit
import RealityKitContent
import Spatial

struct MyImmersiveView: View {
    @State private var step: AppStep = .welcome

    @Binding var backgroundisdark: Bool
    
    var body: some View {
        RealityView { content, attachments in
            if let myAttachment = attachments.entity(for: "welcomePanel") {
                let headAnchor = AnchorEntity(.head)
                myAttachment.transform.translation.z = -1
                headAnchor.addChild(myAttachment)
                content.add(headAnchor)
            }
        } attachments: {
            
            Attachment(id: "welcomePanel") {
                WelcomeMessageView()
                    .frame(width: 600, height: 400)
                    .task {
                        try? await Task.sleep(for: .seconds(3))
                        backgroundisdark = true
                        
                    }
            }
            
        }
        .preferredSurroundingsEffect(backgroundisdark ? .dark : .none)
    }
}

