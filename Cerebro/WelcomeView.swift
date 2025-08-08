import SwiftUI

struct WelcomeView: View {
    @Binding var step: AppStep
    @Binding var backgroundisdark: Bool
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @State private var appear = false

    var body: some View {
        
        VStack(spacing: 30) {
            Text("Welcome To")
                .font(.system(size: 50))
                .fontWeight(.bold)
            Text("SEEK.")
                .font(.system(size: 80))
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("")
            Text("Assess your spatial memory")
                .font(.system(size: 50))
                .padding(.horizontal)
                .foregroundColor(.white)

            HStack(spacing: 30) {
                Button(action: {
                    step = .worldSelection
                }) {
                    Text("Begin")
                        .font(.system(size: 50))
                        .padding() // 👈 Internal padding around text
                }
                .buttonStyle(.borderedProminent)
                
//                Button("") {
//                    step = .exit
//                }
//                .buttonStyle(.bordered)
//                .font(.system(size: 50))
            }
        }
        .opacity(appear ? 1 : 0) //
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) {
                appear = true
            }
        }
        .padding()
    }
}

