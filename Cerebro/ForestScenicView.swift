import SwiftUI
import RealityKit
import RealityKitContent

struct ForestSceneView: View {
    @State private var darken = true

    var body: some View {
        ZStack {
            RealityView { content in
                if let forest = try? await Entity(named: "forestView", in: realityKitContentBundle) {
                    content.add(forest)
                }
            }

            Rectangle()
                .fill(Color.black.opacity(darken ? 1 : 0))
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.5)) {
                        darken = false
                    }
                }
        }
    }
}

