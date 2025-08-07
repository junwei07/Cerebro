//
//  ScoreView.swift
//  Cerebro
//
//  Created by Interactive 3D Design Group on 7/8/25.
//
import SwiftUI

struct ScoreView: View {
    @ObservedObject var appState: AppState
    @Binding var tries: Int
    @Binding var totalCorrect: Int
    
    let orbs : [Orb]
    let selectedOrbs : [Orb]
    
    var correct: Int {
        if orbs.count == selectedOrbs.count {
            return zip(orbs, selectedOrbs).filter { $0 == $1 }.count
        }
        return 0
    }
    
    var score: Float {
        if orbs.count == selectedOrbs.count {
            print("totalCorrect: \(totalCorrect)")
            print("orbsCount: \(orbs.count)")
            print("tries: \(tries)")
            
            return (Float(totalCorrect) / (Float(orbs.count) * Float(tries))) * Float(100)
        }
        return 0
    }

    var body: some View {
        
            VStack {
                if (orbs.count == selectedOrbs.count){
                    
                    Text("Number of Tries: \(tries)")
                        .font(.title)
                        .foregroundStyle(.white)
                    Text("Current Score: \(correct) / \(orbs.count)")
                        .font(.title)
                        .foregroundStyle(.green)
                    
                    Text("Total Score: \(String(format: "%.2f", score))%")
                        .font(.title)
                        .foregroundStyle(.white)
                    Button("Try Again") {
                        appState.disperse = false
                        totalCorrect += correct
                        tries += 1
                    }
                }
            }
            .padding(25)
            .frame(width: 600)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 20)
            )
            
        }
    
}

#Preview {
//    ScoreView(orbs: <#T##[Orb]#>, selectedOrbs: <#T##[Orb]#>, tries: <#T##Int#>)
}
