import SwiftUI

struct VictoryView: View {
    @ObservedObject var gameState: GameState
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Level Complete!")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "00ff87"))

                Text(gameState.currentLevel.name)
                    .font(.system(size: 20, design: .monospaced))
                    .foregroundColor(.white)

                HStack(spacing: 16) {
                    if hasNextLevel {
                        Button(action: {
                            if let nextLevel = Level.allLevels.first(where: { $0.id == gameState.currentLevel.id + 1 }) {
                                gameState.loadLevel(nextLevel)
                            }
                        }) {
                            HStack {
                                Text("Next Level")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(hex: "00ff87"))
                            .foregroundColor(Color(hex: "1a1a2e"))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .keyboardShortcut(.defaultAction)
                    }

                    Button(action: {
                        gameState.resetRobot()
                    }) {
                        HStack {
                            Text("Try Again")
                            Image(systemName: "arrow.counterclockwise")
                        }
                        .font(.system(size: 16, design: .monospaced))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(hex: "1a1a2e"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(40)
            .background(Color(hex: "0f0f1e"))
            .cornerRadius(16)
            .shadow(radius: 20)

            if showConfetti {
                ConfettiView()
            }
        }
        .onAppear {
            showConfetti = true
        }
    }

    private var hasNextLevel: Bool {
        gameState.currentLevel.id < Level.allLevels.count
    }
}

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    Text(piece.emoji)
                        .font(.system(size: 30))
                        .position(piece.position)
                        .opacity(piece.opacity)
                }
            }
            .onAppear {
                generateConfetti(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func generateConfetti(in size: CGSize) {
        let emojis = ["🎉", "⭐️", "✨", "🌟", "💫", "🎊"]

        for _ in 0..<50 {
            let piece = ConfettiPiece(
                emoji: emojis.randomElement()!,
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: -100...0)
                ),
                opacity: 1.0
            )
            confettiPieces.append(piece)
        }

        for i in confettiPieces.indices {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 2...4)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: duration)) {
                    confettiPieces[i].position.y = size.height + 100
                    confettiPieces[i].opacity = 0
                }
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let emoji: String
    var position: CGPoint
    var opacity: Double
}
