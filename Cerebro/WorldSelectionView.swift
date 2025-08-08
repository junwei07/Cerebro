import SwiftUI

struct WorldSelectionView: View {
    @Binding var step: AppStep
    @State private var appear = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Please select your visual experience for today.")
                .font(.custom("AppleGaramond", size: 50))

            HStack(spacing: 35) {
                Button("Forest") {
                    step = .musicSelection
                }
                .font(.system(size: 30))
                .buttonStyle(.borderedProminent)

                Button("Beach") {
                    // Empty for demo
                }
                .font(.system(size: 30))
                .buttonStyle(.bordered)

                Button("Mountain") {
                    // Empty for demo
                }
                .font(.system(size: 30))
                .buttonStyle(.bordered)
            }
        }
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) {
                appear = true
            }
        }
        .padding()
    }
}

