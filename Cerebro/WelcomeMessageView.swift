import SwiftUI
import AVFoundation

struct WelcomeMessageView: View {
    @State private var appear = false
    @State private var audioPlayer: AVAudioPlayer?

    enum controlerAttachment {
        case welcomeview, hiddenview
    }

    @State var attachmentState: controlerAttachment = .welcomeview
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack {
            switch attachmentState {
            case .welcomeview:
                Text("Welcome to Seek.")
                    .font(.custom("AppleGaramond", size: 90))
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)
                    .opacity(appear ? 1 : 0)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            appear = true
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            playAudio(named: "open")
                        }
                    }
                    .task {
                        try? await Task.sleep(for: .seconds(3))
                        withAnimation(.easeInOut(duration: 0.5)) {
                            attachmentState = .hiddenview
                        }
                        try? await Task.sleep(for: .seconds(0.5))
                        openWindow(id: "MainWindow")
                    }
                    .transition(.opacity)

            case .hiddenview:
                EmptyView()
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.5), value: attachmentState)
    }

    func playAudio(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Audio file '\(name).mp3' not found.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
}

