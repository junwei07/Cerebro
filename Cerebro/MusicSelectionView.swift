import SwiftUI

struct MusicSelectionView: View {
    @Binding var step: AppStep
    var playMusic: (String) -> Void
    @State private var appear = false

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Text("Please select your auditory experience for today.")
                    .font(.custom("AppleGaramond", size: 50))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack(spacing: 15) {
                    Button("Fun Melody") {
                        playMusic("calm_melody")
                        step = .instruction
                    }
                    .font(.system(size: 30))
                    .frame(minWidth: 200, minHeight: 60)
                    .buttonStyle(.borderedProminent)

                    Button("Calm Melody") {
                        // Empty
                    }
                    .font(.system(size: 30))
                    .frame(minWidth: 200, minHeight: 60)
                    .buttonStyle(.bordered)

                    Button("Energetic Melody") {
                        // Empty
                    }
                    .font(.system(size: 30))
                    .frame(minWidth: 200, minHeight: 60)
                    .buttonStyle(.bordered)
                }
            }
            .padding()

            VStack {
                Spacer()
                Button("Back") {
                    step = .worldSelection
                }
                .font(.system(size: 30))
                .frame(minWidth: 100, minHeight: 44)
                .buttonStyle(.bordered)
                .padding(.bottom, 100)
            }
        }
        .opacity(appear ? 1 : 0) 
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) {
                appear = true
            }
        }
    }
}

