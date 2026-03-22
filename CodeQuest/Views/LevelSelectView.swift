import SwiftUI

struct LevelSelectView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text("Level Select")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(Color(hex: "00ff87"))

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Level.allLevels, id: \.id) { level in
                        LevelCard(
                            level: level,
                            isCompleted: gameState.completedLevels.contains(level.id),
                            onSelect: {
                                gameState.loadLevel(level)
                                dismiss()
                            }
                        )
                    }
                }
                .padding()
            }

            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
        }
        .frame(width: 500, height: 600)
        .background(Color(hex: "1a1a2e"))
    }
}

struct LevelCard: View {
    let level: Level
    let isCompleted: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Level \(level.id)")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(.gray)

                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "00ff87"))
                        }
                    }

                    Text(level.name)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Text(level.description)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(hex: "0f0f1e"))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isCompleted ? Color(hex: "00ff87") : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
