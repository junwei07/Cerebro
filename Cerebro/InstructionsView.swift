import SwiftUI
import AVFoundation

struct InstructionsView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Binding var step: AppStep
    @State private var audioPlayer: AVAudioPlayer?
    @State private var appear = false
    @State private var nextWindow : Bool = false

    var body: some View {
        VStack(spacing: 30) {
            
            Text("""
                You will now see five colored spheres, each linked to a distinct musical chord. 
                
                These spheres will appear in different areas of the room, and you’ll have 6 seconds to observe and memorise their locations and associated chords.
                
                Your task is to recall and select each sphere in the correct sequence according to the melody.
                
                When you're ready to begin, click "Start."
                """)
                .font(.custom("AppleGaramond", size: 33))
                .multilineTextAlignment(.center)
                .padding()
            
            if nextWindow {
                Button("Start") {
                    dismissWindow(id: "MainWindow")
                    openWindow(id: "ContentView")
                    // Replace with your next step
                }
                .buttonStyle(.borderedProminent)
                .font(.system(size: 35))
                .frame(minWidth: 200, minHeight: 60)
                .buttonStyle(.bordered)
            }
        }
        .opacity(appear ? 1 : 0) 
        .padding()
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) {
                appear = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                playAudio(named: "instructions")
            }
        }
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
            nextWindow = true
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
}

