import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState(level: Level.allLevels[0])
    @State private var showLevelSelect = false

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                CommandPaletteView(gameState: gameState)

                Divider()

                ProgramView(gameState: gameState)

                Divider()

                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            showLevelSelect = true
                        }) {
                            HStack {
                                Image(systemName: "list.bullet")
                                Text("Levels")
                            }
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Color(hex: "00ff87"))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(12)

                        Spacer()

                        Text("Level \(gameState.currentLevel.id): \(gameState.currentLevel.name)")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        Spacer()

                        Text("\(gameState.completedLevels.count)/\(Level.allLevels.count)")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.gray)
                            .padding(12)
                    }
                    .background(Color(hex: "0f0f1e"))

                    Divider()

                    GameCanvasView(gameState: gameState)
                }
            }
            .background(Color(hex: "1a1a2e"))

            if gameState.showVictory {
                VictoryView(gameState: gameState)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 1100, height: 700)
        .background(Color(hex: "1a1a2e"))
        .sheet(isPresented: $showLevelSelect) {
            LevelSelectView(gameState: gameState)
        }
    }
}
